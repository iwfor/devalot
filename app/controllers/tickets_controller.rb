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
class TicketsController < ApplicationController
  ################################################################################
  require_authentication(:except => [:show, :list])
  
  ################################################################################
  tagging_helper_for(Ticket)

  ################################################################################
  def list
    @tickets = @project.tickets
  end

  ################################################################################
  def show
    @ticket = @project.tickets.find(params[:id])
  end

  ################################################################################
  def new
    @ticket = Ticket.new
  end

  ################################################################################
  def create
    strip_invalid_keys(params[:ticket], :severity_id)
    @ticket = @project.tickets.build(params[:ticket], params[:filtered_text], current_user)

    if @ticket.save
      redirect_to(:action => 'show', :id => @ticket, :project => @project)
      return
    end

    render(:action => 'new')
  end

  ################################################################################
  def update
    @ticket = @project.tickets.find(params[:id])

    when_authorized(:can_edit_tickets) do
      @ticket.attributes = params[:ticket]
      @ticket.change_user = current_user

      @ticket.summary.attributes = params[:filtered_text]
      @ticket.summary.updated_by = current_user

      conditional_render(@ticket.save && @ticket.summary.save, :id => @ticket)
    end
  end

  ################################################################################
  def edit_summary
    @ticket = @project.tickets.find(params[:id])
    when_authorized(:can_edit_tickets)
  end

  ################################################################################
  def edit_attrs
    @ticket = @project.tickets.find(params[:id])

    when_authorized(:can_edit_tickets) do
      if request.xhr?
        render(:action => 'edit_attrs.rjs')
      else
        render(:action => 'edit_attrs.rhtml')
      end
    end
  end

end
################################################################################
