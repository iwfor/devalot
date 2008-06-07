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
class TaggingTableHelper < TableMaker::Helper
  ################################################################################
  include TimeFormater
  include PagesHelper
  include TicketsHelper
  include ArticlesHelper
  include ProjectsHelper

  ################################################################################
  columns(:include => [:taggable_type, :taggable, :created_on])
  columns(:order   => [:taggable_type, :taggable, :project, :created_on])

  ################################################################################
  sort(:project, :asc => 'projects.name')

  ################################################################################
  def heading_for_taggable_type
    "Tagged Item"
  end

  ################################################################################
  def display_value_for_taggable_type (tagging)
    if tagging.taggable_type == "Ticket"
      h("Ticket #{tagging.taggable.id} (#{tagging.taggable.state_title})")
    else
      h(tagging.taggable_type)
    end
  end

  ################################################################################
  def display_value_for_project (tagging)
    if tagging.project
      # FIXME have to do the Project.new because something in lib/ext_tagging.rb
      link_to_project(Project.new(tagging.project.attributes))
    else
      "No Project"
    end
  end

  ################################################################################
  def heading_for_taggable
    "Title"
  end

  ################################################################################
  def display_value_for_taggable (tagging)
    item = tagging.taggable

    case item
    when Page
      link_to_page_object(item)
    when Article
      link_to(h(item.title), articles_url('show', item))
    when Ticket
      link_to_ticket(h(item.title), item)
    else
      [:title, :name].each {|m| break item.send(m) if item.respond_to?(m)}
    end
  end

  ################################################################################
  def heading_for_created_on
    "Tagged On"
  end

  ################################################################################
  def display_value_for_created_on (tagging)
    h(format_time_from(tagging.created_on, @controller.current_user))
  end

  ################################################################################
  def self.public? (taggable)
    # FIXME work for current user if he has that project
    return taggable.project.public? if taggable.respond_to?(:project)

    case taggable
    when Article
      if taggable.blog.bloggable.respond_to?(:public?)
        taggable.blog.bloggable.public?
      else
        true
      end
    else
      true
    end
  end

end
################################################################################
