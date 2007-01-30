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
class ConfigController < ApplicationController
  ################################################################################
  require_authorization(:can_admin_project)

  ################################################################################
  def index
  end

  ################################################################################
  def general
    if request.post?
      strip_invalid_keys(params[:prj], :name, :summary, :public)
      @project.attributes = params[:prj]
      @project.public = !params[:prj][:public].blank?
      redirect_to(:action => 'index', :project => @project) if @project.save
    end
  end

  ################################################################################
  def policies
    @policies = @project.policies.find_for_edit

    if request.post?
      @policies.each {|p| p.update_from_params(params[:policy])}

      if @policies.all?(&:valid?)
        @policies.each(&:save!)
        redirect_to(:action => 'index', :project => @project) if @project.save
      end
    end
  end

  ################################################################################
  def description
    if request.post?
      @project.description.attributes = params[:filtered_text]
      redirect_to(:action => 'index', :project => @project) if @project.description.save
    end
  end

  ################################################################################
  def nav
    if request.post?
      @project.nav_content.attributes = params[:filtered_text]
      redirect_to(:action => 'index', :project => @project) if @project.nav_content.save
    end
  end

  ################################################################################
  def feedid
    if request.post?
      @project.generate_feed_id!
      @project.save
      redirect_to(:action => 'index', :project => @project)
    end
  end

end
################################################################################
