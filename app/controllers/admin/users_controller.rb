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
class Admin::UsersController < AdminController
  ################################################################################
  before_filter(:fetch_authenticator)

  ################################################################################
  helper(:dashboard)

  ################################################################################
  table_for(User, :url => {:action => 'list'}, :partial => 'table')

  ################################################################################
  def list
  end

  ################################################################################
  def new
    unless @authenticator.respond_to?(:form_for_create)
      redirect_to(:action => 'list')
      return
    end
  end
  
  ################################################################################
  def create
    @create_result = @authenticator.create_account(params, true)

    if @create_result.respond_to?(:email)
      @user = User.from_account(@create_result)
      update_user
      @user.save
      redirect_to(:action => 'list')
    else
      @user = User.new
      update_user
      render(:action => 'new')
    end
  end

  ################################################################################
  def edit
    unless @authenticator.respond_to?(:form_for_edit)
      redirect_to(:action => 'list')
      return
    end

    @user = User.find(params[:id])
  end

  ################################################################################
  def update
    @user = User.find(params[:id])
    @edit_result = @authenticator.edit_account(params, @user.account_id)

    if @edit_result.respond_to?(:email)
      @user = User.from_account(@edit_result)
      update_user
      @user.save
      redirect_to(:action => 'list')
    else
      update_user
      render(:action => 'edit')
    end
  end

  ################################################################################
  def toggle_enabled
    @user = User.find(params[:id])
    @user.enabled = !@user.enabled
    @user.save
    render(:update) {|p| p.replace_html(:user_table, :partial => 'table')}
  end

  ################################################################################
  private

  ################################################################################
  def update_user
    if !@user.new_record? and @user.points == 0 and params[:user][:points].to_i != 0
      @user.promote_and_make_visible(current_user)
    end

    @user.attributes = params[:user]
    @user.points = params[:user][:points].to_i
    @user.is_root = !params[:user][:is_root].blank?
  end

  ################################################################################
  def fetch_authenticator
    @authenticator = Authenticator.fetch
  end

end
################################################################################
