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
module TicketsHelper
  ################################################################################
  def link_to_ticket (title, ticket)
    ticket = Ticket.find_by_id(ticket) unless ticket.is_a?(Ticket)
    return title unless ticket

    link_to(title, {
      :controller => 'tickets',
      :action     => 'show',
      :id         => ticket,
      :project    => ticket.project,
    })
  end

  ################################################################################
  def link_to_ticket_attr_editor (ticket, use_xhr=true)
    link_with_pencil({
      :controller => 'tickets',
      :action     => 'edit_attrs',
      :id         => ticket,
      :project    => ticket.project,
      :xhr        => use_xhr,
    })
  end

  ################################################################################
  def link_to_ticket_summary_editor (ticket)
    link_with_pencil({
      :controller => 'tickets',
      :action     => 'edit_summary',
      :id         => ticket,
      :project    => ticket.project,
    })
  end

  ################################################################################
  def ticket_table_html
    table_for(Ticket, {
      :object       => @project, 
      :association  => :tickets
    }, {
      :conditions   => ['state in (?)', Ticket::OPEN_STATES],
    }).to_html
  end

end
################################################################################
