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
  # Reserved project slugs (some may clash with controller names)
  RESERVED_SLUGS = %w(account admin dashbord moderate people tags)

  ################################################################################
  # basic validations
  validates_presence_of(:name, :slug, :summary)

  ################################################################################
  # the slug must be unique, other than the ID, it is the way to find a project
  validates_format_of(:slug, :with => /^[\w_-]+$/)
  validates_exclusion_of(:slug, :in => RESERVED_SLUGS)
  validates_uniqueness_of(:slug)

  ################################################################################
  # A project has one FilteredText which contains the description of the project
  belongs_to(:description, :class_name => 'FilteredText', :foreign_key => :description_id)

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
  has_many(:positions, :include => [:user, :role], :order => 'roles.position')
  has_many(:users, :through => :positions)
  
  ################################################################################
  # Attachments are owned by a project to help control access
  has_many(:attachments)

  ################################################################################
  # Policies (settings) for a project
  has_many(:policies, :as => :policy)

  ################################################################################
  # Blogging!
  has_many(:blogs, :as => :bloggable)
  has_many(:articles, :through => :blogs)

  ################################################################################
  # Force slugs to lowercase
  def slug= (slug)
    self[:slug] = slug.downcase
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
    project.rss_id = Digest::MD5.hexdigest("#{project.slug}#{project.object_id}#{Time.now}")
    page = project.pages.create(:title => 'index')
    project.blogs.create(:title => 'News')

    page.create_filtered_text({
      :body       => DefaultPages.fetch('projects', 'index.html'),
      :filter     => 'None',
      :created_by_id => 1,
      :updated_by_id => 1,
    })

    project.create_description({
      :body       => DefaultPages.fetch('projects', 'description.html'),
      :filter     => 'None',
      :created_by_id => 1,
      :updated_by_id => 1,
    }) unless project.has_description?

    project.policies.create({
      :name        => 'public_ticket_interface', 
      :description => 'All tickets can be viewed by the public',
      :value_type  => 'bool',
      :value       => 'true',
    })

    project.policies.create({
      :name        => 'restricted_ticket_interface', 
      :description => 'Users can only view tickets they created',
      :value_type  => 'bool',
      :value       => 'false',
    })

    project.policies.create({
      :name        => 'project_stylesheet', 
      :description => 'Include the given CSS file in the master layout for this project',
      :value_type  => 'str',
      :value       => '',
    })
  end

end
################################################################################
