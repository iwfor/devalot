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
  # This is the file we read to get the default data for the index page
  DEFAULT_INDEX = File.join(RAILS_ROOT, 'config/default-project-index.html')
  
  ################################################################################
  # Each project can have any number of tags
  acts_as_taggable

  ################################################################################
  # basic validations
  validates_presence_of(:name, :slug, :summary)

  ################################################################################
  # the slug must be unique, other than the ID, it is the way to find a project
  validates_format_of(:slug, :with => /^[\w_-]+$/)
  validates_uniqueness_of(:slug)

  ################################################################################
  # A project has one FilteredText which contains the description of the project
  belongs_to(:description, :class_name => 'FilteredText', :foreign_key => :description)

  ################################################################################
  # A project has many tickets
  has_many(:tickets, :order => 'updated_on desc') do
    # make ActiveRecord more flexible
    def build (*a) t=Ticket.new(*a); t.project=proxy_owner; t; end
  end

  ################################################################################
  # A project has many pages
  has_many(:pages)

  ################################################################################
  # Users attached to this project
  has_many(:positions)
  has_many(:users, :through => :positions)
  
  ################################################################################
  # Attachments are owned by a project to help control access
  has_many(:attachments)

  ################################################################################
  # Policies (settings) for a project
  has_many(:policies, :as => :policy)

  ################################################################################
  # Help create a new project
  def initialize (user, project_attributes={}, description_attributes={})
    super(project_attributes)

    self.build_description(description_attributes)
    self.description.created_by = user
    self.description.updated_by = user
  end

  ################################################################################
  # Use the project slug when generating URLs
  def to_param
    self.slug unless self.slug.blank?
  end

  ################################################################################
  private

  ################################################################################
  before_create do |project|
    body = File.open(DEFAULT_INDEX) {|f| f.read}
    page = project.pages.build(:title => 'index')

    page.build_filtered_text(:body => body, :filter => 'None')
    page.filtered_text.created_by = project.description.created_by
    page.filtered_text.updated_by = project.description.updated_by


    project.policies.build({
      :name        => 'public_ticket_interface', 
      :description => 'All tickets can be viewed by the public',
      :value_type  => 'bool',
      :value       => 'true',
    })

    project.policies.build({
      :name        => 'restricted_ticket_interface', 
      :description => 'Users can only view tickets they created',
      :value_type  => 'bool',
      :value       => 'false',
    })
  end

end
################################################################################
