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
class PeopleController < ApplicationController
  ################################################################################
  require_authentication(:except => :show)
  before_filter(:user_check, :except => :show)

  ################################################################################
  without_project

  ################################################################################
  helper(:dashboard)

  ################################################################################
  def show
    @user = User.find(params[:id])

    @pages = Page.find(:all, {
      :include    => :filtered_text, 
      :conditions => ['filtered_texts.updated_by_id = ?', @user.id],
      :order      => 'filtered_texts.updated_on DESC',
      :limit      => 10,
    })

    if @user.has_blogs?
      @blog = @user.blogs.find(:first, :order => :slug)
      @layout_feed = {:blog => @blog, :action => 'articles'}
    end
  end

  ################################################################################
  def edit
  end

  ################################################################################
  def update
    @user.attributes = params[:user]
    @user.policies.each {|p| p.update_from_params(params[:policy])}
    @user.description.attributes = params[:filtered_text]

    if @user.save and @user.policies.each(&:save) and @user.description.save
      redirect_to(:action => 'show', :id => @user)
    else
      render(:action => 'edit')
    end
  end

  ################################################################################
  private

  ################################################################################
  def user_check
    @user = User.find(params[:id])
    return false unless current_user == @user
    return true
  end

end
################################################################################
