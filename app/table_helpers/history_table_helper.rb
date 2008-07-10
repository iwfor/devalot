################################################################################
#
# Copyright (C) 2008 Isaac Foraker <isaac@noscience.net>
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
class HistoryTableHelper < TableMaker::Proxy
  ################################################################################
  include TimeFormater
  include HistoryHelper
  include PeopleHelper
  include ProjectsHelper

  ################################################################################
  columns :include => [:id, :object_type, :action, :created_at, :user]

  ################################################################################
  sort :user, :include => :user, :asc => 'users.first_name, users.last_name', :desc => 'users.first_name DESC, users.last_name DESC'

  ################################################################################
  def url(history)
    url_for_history history
  end

  ################################################################################
  def display_value_for_action(history)
    link_to(h(history.action), url_for_history(history))
  end

  ################################################################################
  def display_value_for_user(history)
    if history.user
      link_to_person history.user
    else
      'no one'
    end
  end

  ################################################################################
  def display_value_for_created_at(history)
    h format_time_from(history.created_at, @controller.current_user)
  end

end
