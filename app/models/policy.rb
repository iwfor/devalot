################################################################################
#
# Copyright (C) 2006 Peter J Jones (pjones@pmade.com)
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
################################################################################
class Policy < ActiveRecord::Base
  ################################################################################
  validates_inclusion_of(:value_type, :in => %w(bool int str))
  validates_uniqueness_of(:name, :scope => [:policy_id, :policy_type])
  validates_presence_of(:description)

  ################################################################################
  belongs_to(:policy, :polymorphic => true)

  ################################################################################
  # Locate the given policy, or raise an error
  def self.lookup (name)
    find_options = {}

    # If we are not being called through an association, restrict database
    # search to non-polymorphic records.  For example, this is a call through
    # an association:
    #
    #  project.policies.check(:foo)
    #
    # and as such, automatically sets :policy_id and :policy_type.  However,
    # a direct call like:
    #
    #  Policy.check(:foo)
    #
    # should directly set those find conditions to avoid fetching an
    # association (polymorphic) record.
    unless self.scoped_methods.find {|m| m[:find]}
      find_options[:conditions] = {:policy_id => nil, :policy_type => nil}
    end

    self.find_by_name(name.to_s, find_options) or raise "invalid policy #{name}"
  end
  
  ################################################################################
  # Locate the given policy, and run a test on it
  def self.check (name, test=nil)
    policy = lookup(name)

    case test
    when Proc
      test.call(policy.value)
    when nil
      policy.value == true
    else
      test == policy.value
    end
  end

  ################################################################################
  # Get all system policies
  def self.system
    self.find(:all, :conditions => {:policy_id => nil, :policy_type => nil})
  end

  ################################################################################
  # Validate the value
  def validate 
    if self[:value_type] == 'int' and !self[:value].match(/^\d+/)
      self.errors.add_to_base("Policy '#{self.name.humanize}' should be a number")
    end
  end

  ################################################################################
  # Get the policy value
  def value 
    case self[:value_type]
    when 'bool'
      self[:value] == 'true'
    when 'int'
      self[:value].to_i
    else
      self[:value]
    end
  end

  ################################################################################
  # Update the value
  def value= (value)
    case self[:value_type]
    when 'bool'
      if value == '1' or value == 'true'
        self[:value] = 'true'
      else
        self[:value] = 'false'
      end
    else
      self[:value] = value
    end
  end
  
  ################################################################################
  # Convert the policy to a string using its value
  def to_s
    self.value.to_s
  end

  ################################################################################
  # Get a form field for this policy
  def form_field (form)
    policy_form = EasyForms::Description.new(self, :prefix => "policy[#{self.id}]") do |f|
      label = "#{self.name.humanize}: (#{self.description})"

      case self[:value_type]
      when 'bool'
        f.check_box(:value, label)
      when 'int', 'str'
        if self.name == 'authenticator'
          f.collection_select(:value, label, Authenticator.list, :to_s, :to_s)
        else
          f.text_field(:value, label)
        end
      end
    end

    form.subform(policy_form)
  end

  ################################################################################
  # Update this policy from a form param hash
  def update_from_params (params)
    attrs = params[self.id.to_s]

    if attrs and attrs[:value]
      self.value = attrs[:value]
    else
      self.value = ''
    end
  end

end
################################################################################
