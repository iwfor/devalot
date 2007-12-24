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
class Project < ActiveRecord::Base
  ################################################################################
  # Reserved project slugs (some may clash with controller names)
  RESERVED_SLUGS = %w(account admin dashbord feed moderate people search system tags)

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
  # In order to support navigation on pages, each project has nav content
  belongs_to(:nav_content, :class_name => 'FilteredText', :foreign_key => :nav_content_id)

  ################################################################################
  # A project has many tickets
  has_many(:tickets, :order => 'updated_on desc') do
    # make ActiveRecord more flexible
    def build (*a) t=Ticket.new(*a); t.project=proxy_owner; t; end
  end
  
  ################################################################################
  # A project has many timeline entries
  has_many(:timeline_entries, :order => 'created_at DESC')

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
  # has_many(:articles, :through => :blogs) This doesn't seem to work

  ################################################################################
  # Force slugs to lowercase
  def slug= (slug)
    self[:slug] = slug.downcase
  end

  ################################################################################
  def generate_feed_id!
    self.rss_id = Digest::MD5.hexdigest("#{self.slug}#{self.object_id}#{Time.now}")
  end

  ################################################################################
  # Use the project slug when generating URLs
  def to_param
    self.slug unless self.slug.blank?
  end

  ################################################################################
  # Returns all tags that are somehow associated with this project
  def tags
    Tag.find_for_project(self.id)
  end

  ################################################################################
  # For use in duck-typing, just return self
  def project
    self
  end

  ################################################################################
  # Convert the Project to a string using the name
  def to_s
    name.to_s
  end

  ################################################################################
  private

  ################################################################################
  before_create do |project|
    project.generate_feed_id!
    page = project.pages.create(:title => 'index')
    project.blogs.create(:title => 'News', :slug => 'news')

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

    project.create_nav_content({
      :body       => DefaultPages.fetch('projects', 'nav_content.html'),
      :filter     => 'None',
      :created_by_id => 1,
      :updated_by_id => 1,
    }) unless project.has_nav_content?

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

    project.policies.create({
      :name        => 'use_ticket_system', 
      :description => 'This project uses tickets',
      :value_type  => 'bool',
      :value       => 'true',
    })
  
    # Added 2007-10-24 by Sam Lown <dev at samlown.com>
    project.policies.create({
      :name        => 'use_timeline_system', 
      :description => 'This project provides a timeline of changes',
      :value_type  => 'bool',
      :value       => 'true',
    })

    project.policies.create({
      :name        => 'use_blog_system', 
      :description => 'This project has a blog',
      :value_type  => 'bool',
      :value       => 'true',
    })

    project.policies.create({
      :name        => 'members_are_public', 
      :description => 'The member list is open to the public',
      :value_type  => 'bool',
      :value       => 'true',
    })
  end

end
################################################################################
