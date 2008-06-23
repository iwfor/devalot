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
class MembersController < ApplicationController
  ################################################################################
  require_authorization(:can_edit_users, :except => [:index, :list, :redraw_position_table])
  before_filter(:public_member_list)

  ################################################################################
  table_for(Position, :url => lambda {|c| {:project => c.send(:project)}}, :partial => 'table')

  ################################################################################
  def index
    list
    render(:action => 'list')
  end

  ################################################################################
  def list
  end

  ################################################################################
  def new
  end

  ################################################################################
  def create
    @create_errors = []

    person = User.find_by_email(params[:email])
    @create_errors << 'No user with that email address could be found' if person.nil?

    all_roles = current_user.role_list_for(@project)
    role = all_roles.find {|r| r.position == params[:role].to_i}
    @create_errors << 'You cannot assign that role to this project' if role.nil?

    if @create_errors.blank?
      person.positions.create(:role => role, :project => @project)
      redirect_to(:action => 'index', :project => @project)
    else
      render(:action => 'new')
    end
  end

  ################################################################################
  def edit
    @position = @project.positions.find(params[:id])
    @my_position = current_user.positions.find_by_project_id(@project.id)
    when_authorized(:condition => @position.role.position >= @my_position.role.position)
  end

  ################################################################################
  def update
    @position = @project.positions.find(params[:id])
    @my_position = current_user.positions.find_by_project_id(@project.id)

    when_authorized(:condition => @position.role.position >= @my_position.role.position) do
      role = current_user.role_list_for(@project).find {|r| r.id == params[:position][:role_id].to_i}
      @position.role = role unless role.blank?
      @position.save
      redirect_to(:action => 'index', :project => @project)
    end
  end

  ################################################################################
  def destroy
    @position = @project.positions.find(params[:id])
    @my_position = current_user.positions.find_by_project_id(@project.id)

    when_authorized(:condition => @position.role.position >= @my_position.role.position) do
      # XXX Why is this failing?
      @position.destroy
      redirect_to(:action => 'index', :project => @project)
    end
  end

  ################################################################################
  def public_member_list
    return true if current_user.projects.include?(@project)
    @project.policies.check(:members_are_public)
  end

end
################################################################################
