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
class Page < ActiveRecord::Base
  ##############################################################################
  acts_as_ferret :fields => {
    :project => {},
    :title => { :boost => 1.3 },
    :body => { :boost => 1.0 },
    :tags => { :boost => 1.2 }
  },
  :store_class_name => true

  ##############################################################################
  attr_protected :project_id

  ##############################################################################
  # Each page can have any number of tags
  acts_as_taggable

  ##############################################################################
  validates_presence_of :title
  validates_uniqueness_of :title, :scope => :project_id
  validates_uniqueness_of :slug , :scope => :project_id
  attr_protected(:created_by, :updated_by)

  ##############################################################################
  # Each page belongs to a project
  belongs_to :project
  belongs_to :created_by, :class_name => 'User', :foreign_key => :created_by_id
  belongs_to :updated_by, :class_name => 'User', :foreign_key => :updated_by_id

  ##############################################################################
  has_many :comments, :as => :commentable, :dependent => :destroy
  has_history
  has_watchers

  ################################################################################
  # Force slugs to lowercase
  def slug= (slug)
    self[:slug] = slug.downcase
  end

  ##############################################################################
  # Locate a system page, which is any page that does not belong to a project.
  def self.system (slug)
    self.find(:first, :conditions => {:slug => slug, :project_id => nil})
  end

  ##############################################################################
  def tagging_added (tagging)
    tagging.project_id = self.project_id
  end

  ##############################################################################
  # Use the page slug as the ID
  def to_param
    self.slug unless self.slug.blank?
  end

  ##############################################################################
  # For notification, generate a title
  def notification_title
    self.title
  end

  ##############################################################################
  # For notification, generate a summary
  def notification_summary
    h("#{self.body[0..100]}\n")
  end

  ##############################################################################
  # Log history when record is created.
  after_create do |record|
    changes = []
    [:title, :slug, :body, :body_filter, :toc_element].each do |field|
      value = record.send(field)
      changes << { :action => 'create', :field => field.to_s, :value => value } unless value.blank?
    end
    record.history.create_record "Created '#{record.title}'", record.updated_by, changes
  end

  ##############################################################################
  # Log history when record is changed.
  before_update do |record|
    old_record= record.class.find(record.id)
    changes = []
    [:title, :slug, :body, :body_filter, :toc_element].each do |field|
      value = record.send(field)
      if value != old_record.send(field)
        changes << {:action => 'edit', :field => field.to_s, :value => value}
      end
    end
    unless changes.empty?
      record.history.create_record "Edited '#{record.title}'", record.updated_by, changes
    end
  end

  ##############################################################################
  # Log history when a record is deleted.
  before_destroy do |record|
    record.history.create_record "Deleted '#{record.title}'"
  end
end
################################################################################
