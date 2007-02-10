################################################################################
#
# Copyright (C) 2006-2007 pmade inc. (Peter Jones pjones@pmade.com)
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
class User < ActiveRecord::Base
  ################################################################################
  CONTENT_ASSOCIATIONS = [:created_tickets, :comments]

  ################################################################################
  attr_protected(:is_root, :points)

  ################################################################################
  validates_presence_of(:first_name, :last_name, :email)

  ################################################################################
  validates_uniqueness_of(:email)
  
  ################################################################################
  # Policies (settings) for a user
  has_many(:policies, :as => :policy)

  ################################################################################
  # A FilteredText which contains the description for this user
  belongs_to(:description, :class_name => 'FilteredText', :foreign_key => :description_id)

  ################################################################################
  has_many(:positions, :include => [:project, :role], :order => 'projects.name')
  has_many(:projects, :through => :positions)
  
  ################################################################################
  has_many(:blogs, :as => :bloggable)

  ################################################################################
  has_many(:created_tickets,  :class_name => 'Ticket', :foreign_key => 'creator_id')
  has_many(:assigned_tickets, :class_name => 'Ticket', :foreign_key => 'assigned_to_id')

  ################################################################################
  has_many(:comments)

  ################################################################################
  # Locate a user given an email address
  def self.find_by_email (email)
    self.find(:first, :conditions => {:email => email.downcase.strip})
  end

  ################################################################################
  def self.calculate_find_conditions_for_moderated_users
    conditions = ['']
    associations = []

    CONTENT_ASSOCIATIONS.map {|a| self.reflect_on_association(a).table_name}.each do |table|
      associations << "#{table}.visible = ?"
    end

    conditions.first << associations.join(' or ')
    conditions += associations.map {false}
    conditions
  end

  ################################################################################
  # add a bunch of helper methods for figuring out permissions
  Role.column_names.each do |name|
    next unless name.match(/^(?:can|has)_/)

    class_eval <<-END
      def #{name}? (project)
        return true if self.is_root?
        return false unless position = self.positions.find_by_project_id(project.id)
        position.role.#{name} == true
      end
    END
  end

  ################################################################################
  # same with the overall site permissions
  StatusLevel.column_names.each do |name|
    next unless name.match(/^(?:can|has)_/)

    class_eval <<-END
      def #{name}?
        return true if self.is_root?
        self.status_level.#{name} == true
      end
    END
  end

  ################################################################################
  def self.from_account (account)
    user = User.find_by_account_id(account.id) || User.new(:account_id => account.id)

    # copy remote account attributes to the user object
    [:first_name, :last_name, :email].each {|a| user.send("#{a}=", account.send(a))}

    user.save
    user
  end

  ################################################################################
  def name
    "#{self.first_name} #{self.last_name}"
  end

  ################################################################################
  def time_format
    self[:time_format].nil? ? 'smart' : self[:time_format]
  end

  ################################################################################
  def status_level
    StatusLevel.for_points(self.points)
  end

  ################################################################################
  def rating
    point_str = self.points.to_s.reverse.split(/(\d{3})/).reject{|s| s.length == 0}.join(',').reverse

    sl = self.status_level
    sl.title.sub(')', " with #{point_str} point#{'s' if self.points != 1})")
  end

  ################################################################################
  # List of roles at or below my current level
  def role_list_for (project)
    my_position = nil

    if self.is_root?
      my_position = 0
    else
      role = self.positions.find_by_project_id(project.id)
      my_position = role.position unless role.nil?
    end

    return [] if my_position.nil?
    Role.find(:all, :order => :position, :conditions => ['position >= ?', my_position])
  end

  ################################################################################
  # Remove all content this user created and lock their account
  def lock_and_destroy (by_user)
    return false unless self.enabled?

    CONTENT_ASSOCIATIONS.each do |association|
      self.send(association).destroy_all
    end

    self.points = 0
    self.enabled = false
    true
  end

  ################################################################################
  # Make all user content visible and promote their account
  def promote_and_make_visible (by_user)
    return false unless self.points == 0

    CONTENT_ASSOCIATIONS.each do |association|
      self.send(association).each do |obj|
        obj.visible = true
        obj.change_user = by_user if obj.respond_to?(:change_user=)
        obj.save
      end
    end

    self.points += 1
    true
  end

  ################################################################################
  protected

  ################################################################################
  before_create do |user|
    unless user.has_description?
      body = DefaultPages.fetch('users', 'description.html')
      user.create_description(:body => body, :filter => 'None')
    end

    user.policies.create({
      :name        => 'display_user_email', 
      :description => 'Allow registered users to see your email address',
      :value_type  => 'bool',
      :value       => 'true',
    })
  end

end
################################################################################
