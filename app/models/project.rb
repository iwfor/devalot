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
class Project < ActiveRecord::Base
  ################################################################################
  # basic validations
  validates_presence_of(:name, :slug)

  ################################################################################
  # the slug must be unique, other than the ID, it is the way to find a project
  validates_uniqueness_of(:slug)
  validates_format_of(:slug, :with => /^[\w_-]+$/)

  ################################################################################
  # A project has one Wiki page which contains the description of the project
  belongs_to(:description, :class_name => 'Page', :foreign_key => :description_id)

  ################################################################################
  # A project has many tickets
  has_many(:tickets, :order => 'updated_on desc')

  ################################################################################
  # A project has many pages
  has_many(:pages, :order => 'created_on desc')

  ################################################################################
  # Help create a new project
  def self.create (user, project_attributes={}, description_attributes={})
    project = self.new(project_attributes)
    return project unless project.save

    description_attributes[:title] = project.name + " Description"
    description_attributes[:project_id] = project.id

    project.description = Page.new(description_attributes)
    project.description.project = project
    project.description.user = user
    project.description.save

    project
  end

  ################################################################################
  # Use the project slug when generating URLs
  def to_param
    self.slug unless self.slug.blank?
  end

end
################################################################################
