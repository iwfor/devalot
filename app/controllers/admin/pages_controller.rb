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
class Admin::PagesController < AdminController
  ################################################################################
  table_for(Page, :partial => 'table', :url => {})

  ################################################################################
  def list
  end

  ################################################################################
  def new
    @page = Page.new(:title => params[:id] || 'New Page')
  end

  ################################################################################
  def create
    @page = Page.new(params[:page].update(:updated_by_id => current_user.id, :created_by_id => current_user.id))
    conditional_render(@page.save, :url => url_for_page(@page))
  end

  ################################################################################
  def edit
    @page = Page.system(params[:id])
  end

  ################################################################################
  def update
    @page = Page.system(params[:id])
    @page.attributes = params[:page].update(:updated_by_id => current_user.id)
    conditional_render(@page.save, :url => url_for_page(@page))
  end

  ################################################################################
  def destroy
    Page.system(params[:id]).destroy
    redirect_to(:action => 'list')
  end

  ################################################################################
  private

  ################################################################################
  include PagesHelper

end
################################################################################
