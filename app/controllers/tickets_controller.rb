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
class TicketsController < ApplicationController
  ################################################################################
  tagging_helper_for(Ticket)
  comments_helper_for(Ticket)

  ################################################################################
  table_for(Ticket, :url => :url_for_ticket_list, :partial => 'list')
  table_for(Ticket, :url => :url_for_ticket_list, :partial => 'mlist', :id => 'moderated')
  table_for(Attachment, :url => lambda {|c| {:project => c.send(:project), :id => c.params[:id]}} , :partial => 'attachments')
  table_for(TicketHistory, :url => lambda {|c| {:project => c.send(:project), :id => c.params[:id]}} , :partial => 'history')

  ################################################################################
  TAGGING_ACTIONS = [:add_tags_to_ticket, :remove_tags_from_ticket]
  COMMENT_ACTIONS = comment_methods

  LIST_ACTIONS = [:index, :list]
  VIEW_ACTIONS = [:show, :attachments, :history, :attach_file, :redraw_ticket_table, :redraw_ticket_moderated_table, :redraw_attachment_table, :redraw_ticket_history_table]
  OPEN_ACTIONS = LIST_ACTIONS + VIEW_ACTIONS
  ANY_USER_ACTIONS = [:new, :create].concat(OPEN_ACTIONS + TAGGING_ACTIONS + COMMENT_ACTIONS)

  before_filter(:project_uses_tickets)
  before_filter(:policy_check, :only => OPEN_ACTIONS)
  require_authentication(:except => OPEN_ACTIONS)
  require_authorization(:can_edit_tickets, :except => ANY_USER_ACTIONS)
  
  ################################################################################
  before_filter(:lookup_ticket, :except => [:index, :list, :new, :create, :redraw_ticket_table, :redraw_ticket_moderated_table])

  ################################################################################
  helper(:moderate)

  ################################################################################
  def index
    list
    render(:action => 'list')
  end

  ################################################################################
  def list
    @layout_feed = {:project => @project, :code => @project.rss_id, :action => 'tickets', :id => 'all'}
  end

  ################################################################################
  def show
    # @ticket may have been set via policy_check
    @ticket ||= @project.tickets.find(params[:id])
    @layout_feed = {:project => @project, :code => @project.rss_id, :action => 'tickets', :id => @ticket}
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
      @attachment.user = current_user
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
    @ticket.attributes = params[:ticket]
    @ticket.change_user = current_user

    @ticket.summary.attributes = params[:filtered_text] if params[:filtered_text]
    @ticket.summary.updated_by = current_user

    conditional_render(@ticket.save && @ticket.summary.save, :id => @ticket)
  end

  ################################################################################
  def edit_summary
  end

  ################################################################################
  def edit_attrs

    if request.xhr?
      render(:action => 'edit_attrs.rjs')
    else
      render(:action => 'edit_attrs.rhtml')
    end
  end

  ################################################################################
  def take
    @ticket.assigned_to = current_user
    @ticket.change_user = current_user
    @ticket.save
    render(:action => 'update')
  end

  ################################################################################
  def mark_duplicate

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
    if !params[:attachment].blank?
      if !params[:attachment][:filename].blank?
        attachment = @project.attachments.build(params[:attachment])
        attachment.user = current_user
        attachment.attachable = @ticket

        if attachment.save
          @ticket.file_attached(attachment)
          redirect_to(:action => 'show', :id => @ticket, :project => @project)
        else
          @attach_error_message = 'Error Uploading File'
        end
      else
        @attach_error_message = "Please choose a file to upload."
      end
    end
  end

  ################################################################################
  def attachments
    render(:update) do |page|
      page.replace_html(:ticket_files, :partial => 'attachments')
      page.visual_effect(:toggle_slide, :ticket_files)
    end
  end

  ################################################################################
  def history
    render(:update) do |page|
      page.replace_html(:ticket_history, :partial => 'history')
      page.visual_effect(:toggle_slide, :ticket_history)
    end
  end

  ################################################################################
  def change_state
    @ticket.change_state(params[:state].to_sym)
    @ticket.change_user = current_user
    @ticket.save
    render(:action => 'update')
  end

  ################################################################################
  private

  ################################################################################
  include TicketsHelper

  ################################################################################
  def lookup_ticket 
    @ticket ||= @project.tickets.find(params[:id])
  end

  ################################################################################
  def project_uses_tickets
    @project.policies.check(:use_ticket_system)
  end

  ################################################################################
  def policy_check
    return true if current_user.can_edit_tickets?(@project)
    return true if @project.policies.check(:public_ticket_interface)

    if @project.policies.check(:restricted_ticket_interface)
      if VIEW_ACTIONS.include?(@action_name.to_sym)
        return false unless authenticate
        @ticket = @project.tickets.find(params[:id])
        return true if @ticket.creator == current_user
      end
    end

    redirect_to(:action => 'new', :project => @project)
    return false
  end

end
################################################################################
