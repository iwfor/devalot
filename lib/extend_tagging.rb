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
# These classes come from vendor/plugins/tagging and are reopened here to add
# devalot specific features.
class Tag < ActiveRecord::Base
  ################################################################################
  # Find all tags for a given project
  def self.find_for_project (project_id)
    self.find(:all, {
      :select     => 'DISTINCT ON (tags.name) tags.*',
      :joins      => 'LEFT JOIN taggings ON taggings.tag_id = tags.id',
      :conditions => ['taggings.project_id = ?', project_id],
      :order      => 'tags.name',
    })
  end

  ################################################################################
  # Find all tags that the given user is allowed to see.  see
  def self.find_for_user (for_user)
    conditions = nil
    
    unless for_user.is_root?
     conditions = ['taggings.project_id IS NULL OR projects.public = ?', true]

      if !(user_projects = for_user.projects.map(&:id)).empty?
        conditions.first << ' OR projects.id in (?)'
        conditions << user_projects
      end
    end

    self.find(:all, {
      :select     => 'DISTINCT ON (tags.name) tags.*',
      :joins      => 'LEFT JOIN taggings ON taggings.tag_id = tags.id LEFT JOIN projects on taggings.project_id = projects.id',
      :conditions => conditions,
      :order      => 'tags.name',
    })
  end

end

################################################################################
class Tagging < ActiveRecord::Base
  ################################################################################
  # FIXME this belongs_to call causes tagging.project to return a plain
  # Project class, and not the one from app/models/project.rb, WTF?
  belongs_to(:project)

  ################################################################################
  # Returns the hash used in a call to find(:all) for finding a tagging in
  # a given project.
  def self.options_to_find_tag_in_project (project)
    {
      :conditions => ['taggings.project_id = ?', project.id]
    }
  end

  ################################################################################
  # Returns the hash used in a call to find(:all) for finding all taggings
  # that a give user can see.
  def self.options_to_find_tag_for_user (user)
    conditions = nil

    unless user.is_root?
      conditions = ['taggings.project_id IS NULL OR projects.public = ?', true]

      if !(user_projects = user.projects.map(&:id)).empty?
        conditions.first << " OR projects.id in (?)"
        conditions << user_projects
      end
    end

    {
      :select     => 'taggings.*',
      :joins      => 'LEFT JOIN projects ON projects.id = taggings.project_id',
      :conditions => conditions,
    }
  end

end
################################################################################
