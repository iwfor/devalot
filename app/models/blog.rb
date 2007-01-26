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
class Blog < ActiveRecord::Base
  ################################################################################
  validates_presence_of(:title)
  validates_presence_of(:slug)

  ################################################################################
  # Hacked from vendor/rails/activerecord/lib/active_record/validations.rb
  # Special verion of validates_uniqueness_of
  validates_each(:slug) do |record, attr_name, value|
    configuration = {:message => ActiveRecord::Errors.default_error_messages[:taken]}
    condition_sql = "UPPER(#{record.class.table_name}.#{attr_name}) #{attribute_condition(value)}"
    condition_params = [value.upcase]

    scope = 
      case record.bloggable
      when Project
        # Blogs can each have their own slugs without being unique across all blogs
        [:bloggable_type, :bloggable_id]
      when User
        # Users need to have unique slugs across all users
        [:bloggable_type]
      else
        []
      end

    scope.map do |scope_item|
      scope_value = record.send(scope_item)
      condition_sql << " AND #{record.class.table_name}.#{scope_item} #{attribute_condition(scope_value)}"
      condition_params << scope_value
    end

    unless record.new_record?
      condition_sql << " AND #{record.class.table_name}.#{record.class.primary_key} <> ?"
      condition_params << record.send(:id)
    end

    if record.class.find(:first, :conditions => [condition_sql, *condition_params])
      record.errors.add(attr_name, configuration[:message])
    end
  end

  ################################################################################
  belongs_to(:bloggable, :polymorphic => true)

  ################################################################################
  has_many(:articles)

  ################################################################################
  def self.find (*args)
    if args.first.is_a?(String) and !args.first.match(/^\d$/)
      self.find_by_slug(args.first)
    else
      super
    end
  end

  ################################################################################
  def to_param
    self.slug
  end

end
################################################################################
