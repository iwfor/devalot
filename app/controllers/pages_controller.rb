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
class PagesController < ApplicationController
  ################################################################################
  require_authentication(:except => :show)
  require_authorization(:can_create_pages, :only => [:new, :create])

  ################################################################################
  tagging_helper_for(Page)
  comments_helper_for(Page)

  ################################################################################
  def show
    @layout_feed = {:blog => 'news', :project => @project, :action => 'articles'}
    @layout_feed[:code] = @project.rss_id unless @project.public?

    @page = @project.pages.find_by_title(params[:id])
  end

  ################################################################################
  def new
    @page = @project.pages.build(:title => (params[:id] || 'New Page'))
  end

  ################################################################################
  def create
    @page = @project.pages.build(params[:page])
    @page.title = params[:id]

    @page.build_filtered_text(params[:filtered_text])
    @page.filtered_text.created_by = current_user
    @page.filtered_text.updated_by = current_user

    conditional_render(@page.save, :id => @page)
  end

  ################################################################################
  def edit
    @page = @project.pages.find_by_title(params[:id])
    when_authorized(:can_edit_pages, :or_user_matches => @page.filtered_text.created_by)
  end

  ################################################################################
  def update
    @page = @project.pages.find_by_title(params[:id])

    when_authorized(:can_edit_pages, :or_user_matches => @page.filtered_text.created_by) do
      @page.attributes = params[:page]
      @page.filtered_text.attributes = params[:filtered_text]
      @page.filtered_text.updated_by = current_user
      conditional_render(@page.save && @page.filtered_text.save, :id => @page)
    end
  end

end
################################################################################
