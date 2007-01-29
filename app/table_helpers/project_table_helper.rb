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
class ProjectTableHelper < TableMaker::Proxy
  ################################################################################
  include TimeFormater

  ################################################################################
  columns(:only => [:id, :name, :slug, :summary, :users, :public, :created_on])

  ################################################################################
  def display_value_for_name (project)
    link_to(h(project.name), :controller => '/pages', :action => 'show', :id => 'index', :project => project)
  end

  ################################################################################
  def display_value_for_summary (project)
    truncate(project.summary)
  end

  ################################################################################
  def heading_for_users
    "Members"
  end

  ################################################################################
  def display_value_for_users (project)
    link_to(h(project.users.count), :controller => '/members', :project => project)
  end

  ################################################################################
  def display_value_for_public (project)
    project.public? ? 'Yes' : 'No'
  end

  ################################################################################
  def display_value_for_created_on (project)
    format_time_from(project.created_on, @controller.current_user)
  end

end
################################################################################
