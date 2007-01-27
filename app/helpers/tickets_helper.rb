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
  def url_for_ticket (ticket)
    {:controller => 'tickets', :action => 'show', :id => ticket, :project => ticket.project, :only_path => false}
  end

  ################################################################################
  def url_for_ticket_list
    {:controller => 'tickets', :action => 'list', :project => @project, :only_path => false}
  end

  ################################################################################
  def link_to_ticket (title, ticket)
    ticket = Ticket.find_by_id(ticket) unless ticket.is_a?(Ticket)
    return title unless ticket

    link_to(title, url_for_ticket(ticket))
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
  def ticket_table_html (visible=true, id=nil)
    table_for(Ticket, {
      :object       => @project, 
      :association  => :tickets,
      :id           => id,
      :sort         => [:updated_on, :desc],
    }, {
      :conditions   => ['state in (?) and visible = ?', Ticket::OPEN_STATES, visible],
    }).to_html({
      :if_none      => '<h2>No Tickets<h2>',
    })
  end
  
  ################################################################################
  def ticket_action (title, action, options={})
    configuration = {
      :url     => {},
      :xhr     => true,
      :id      => title.underscore,
      :confirm => "Are you sure?",
    }.update(options)

    url = {:action => action, :id => @ticket, :project => @ticket.project}.update(configuration.delete(:url))

    form_options = {
      :id      => configuration[:id],
      :url     => url,
      :xhr     => configuration[:xhr],
      :label   => configuration[:confirm],
      :button  => 'OK',
      :cancel  => true,
      :field   => :none
    }

    @fast_forms ||= ''
    @fast_forms << generate_fast_form(form_options)

    link_to_function(title) {|p| p << visual_effect(:toggle_slide, configuration[:id])}
  end

  ################################################################################
  def ticket_take_link
    return nil if @ticket.assigned_to == current_user
    ticket_action('Take', 'take', :confirm => "Are you sure you want to be assigned to ticket #{@ticket.id}?")
  end

  ################################################################################
  def ticket_form (form, options={})
    configuration = {
      :title => false,

    }.update(options)

    form.text_field(:title, "Title:") if configuration[:title]
    form.collection_select(:severity_id, "Severity:", Severity.find(:all), :id, :title)

    if current_user.projects.include?(@ticket.project)
      form.collection_select(:priority_id, "Priority:", Priority.find(:all), :id, :title)

      users = @ticket.project.users.map {|u| [u.id, u.name]}
      users.unshift([0, 'No One'])
      form.collection_select(:assigned_to_id, "Assigned To:", users, :first, :last)
    end
  end

end
################################################################################
