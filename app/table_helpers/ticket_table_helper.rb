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
class TicketTableHelper < TableMaker::Proxy
  ################################################################################
  include TimeFormater
  include TicketsHelper
  include PeopleHelper
  include ProjectsHelper

  ################################################################################
  columns(:only => [:id, :title, :state, :severity, :priority, :assigned_to, :creator, :created_on, :updated_on])
  columns(:hide => [:created_on])
  
  ################################################################################
  sort(:priority, :include => :priority, :asc => 'priorities.position')
  sort(:severity, :include => :severity, :asc => 'severities.position')
  sort(:assigned_to, :include => :assigned_to, :asc => 'users.first_name, users.last_name', :desc => 'users.first_name DESC, users.last_name DESC')

  ################################################################################
  def url (ticket)
    url_for_ticket(ticket)
  end

  ################################################################################
  def display_value_for_title (ticket)
    link_to(h(truncate(ticket.title, 28)), url_for_ticket(ticket), :title => h(ticket.title))
  end

  ################################################################################
  def display_value_for_assigned_to (ticket)
    if ticket.assigned_to
      link_to_person(ticket.assigned_to)
    else
      'no one'
    end
  end

  ################################################################################
  def display_value_for_creator (ticket)
    link_to_person(ticket.creator)
  end

  ################################################################################
  def display_value_for_project (ticket)
    link_to_project(ticket.project)
  end

  ################################################################################
  def display_value_for_state (ticket)
    ticket.state_title
  end

  ################################################################################
  def display_value_for_created_on (ticket)
    format_time_from(ticket.created_on, @controller.current_user)
  end

  ################################################################################
  def display_value_for_updated_on (ticket)
    format_time_from(ticket.updated_on, @controller.current_user)
  end

end
################################################################################
