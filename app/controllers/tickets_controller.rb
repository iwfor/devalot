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
  OPEN_ACTIONS = [:show, :list, :index, :attachments]
  require_authentication(:except => OPEN_ACTIONS)
  require_authorization(:can_edit_tickets, :except => [:new, :create].concat(OPEN_ACTIONS))
  
  ################################################################################
  tagging_helper_for(Ticket)

  ################################################################################
  def index
    render(:action => 'list')
  end

  ################################################################################
  def list
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
    strip_invalid_keys(params[:ticket], :severity_id) unless current_user.projects.include?(@project)
    # FIXME take out of :ticket below so it will reload right
    initial_tags = params[:ticket].delete(:tags)

    @ticket = @project.tickets.build(params[:ticket], params[:filtered_text], current_user)

    unless params[:attachment][:filename].blank?
      @attachment = @project.attachments.build(params[:attachment])
      @ticket.attachments << @attachment
    end

    if @ticket.save
      @ticket.tags.add(initial_tags) unless initial_tags.blank?
      redirect_to(:action => 'show', :id => @ticket, :project => @project)
      return
    end

    render(:action => 'new')
  end

  ################################################################################
  def update
    @ticket = @project.tickets.find(params[:id])
    @ticket.attributes = params[:ticket]
    @ticket.change_user = current_user

    @ticket.summary.attributes = params[:filtered_text] if params[:filtered_text]
    @ticket.summary.updated_by = current_user

    conditional_render(@ticket.save && @ticket.summary.save, :id => @ticket)
  end

  ################################################################################
  def edit_summary
    @ticket = @project.tickets.find(params[:id])
  end

  ################################################################################
  def edit_attrs
    @ticket = @project.tickets.find(params[:id])

    if request.xhr?
      render(:action => 'edit_attrs.rjs')
    else
      render(:action => 'edit_attrs.rhtml')
    end
  end

  ################################################################################
  def take
    @ticket = @project.tickets.find(params[:id])
    @ticket.assigned_to = current_user
    @ticket.change_user = current_user
    @ticket.save
    render(:action => 'update')
  end

  ################################################################################
  def mark_duplicate
    @ticket = @project.tickets.find(params[:id])

    if @ticket.mark_duplicate_of(params[:duplicate_id].to_i) 
      @ticket.change_user = current_user
      @ticket.save
    else
      @attributes_error_message = 'Invalid Ticket ID'
    end

    render(:action => 'update')
  end

  ################################################################################
  def attach_file 
    if request.post?
      @ticket = @project.tickets.find(params[:id])

      attachment = @project.attachments.build(params[:attachment])
      attachment.user = current_user
      attachment.attachable = @ticket

      unless attachment.save
        @attributes_error_message = 'Error Uploading File'
      end

      redirect_to(:action => 'show', :id => @ticket, :project => @project)
    end
  end

  ################################################################################
  def attachments
    @ticket = @project.tickets.find(params[:id])

    render(:update) do |page|
      page.replace_html(:ticket_files, :partial => 'attachments')
      page.visual_effect(:toggle_slide, :ticket_files)
    end
  end

  ################################################################################
  def change_state
    @ticket = @project.tickets.find(params[:id])
    @ticket.change_state(params[:state].to_sym)
    @ticket.change_user = current_user
    @ticket.save
    render(:action => 'update')
  end

end
################################################################################
