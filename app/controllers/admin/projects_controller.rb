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
class Admin::ProjectsController < AdminController
  ################################################################################
  table_for(Project, :url => {}, :partial => 'table')

  ################################################################################
  def list
  end

  ################################################################################
  def new
    # can't call it @project because that's magic in this app
    @prj = Project.new
  end

  ################################################################################
  def create
    @prj = Project.new(params[:project])
    @email_error = nil

    unless params[:admin].blank?
      # before we save the new project, validate the admin user
      @admin = User.find_by_email(params[:admin])
      @email_error = true if @admin.nil?
    end

    conditional_render(@email_error.nil? && @prj.save, :redirect_to => 'list')

    if @prj.valid? and !@admin.nil?
      # now that the project is saved, setup the initial admin user
      role = Role.find(:first, :order => :position)
      @admin.positions.create(:role => role, :project => @prj)
    end
  end

end
################################################################################
