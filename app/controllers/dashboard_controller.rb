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
class DashboardController < ApplicationController
  ################################################################################
  require_authentication

  ################################################################################
  without_project

  ################################################################################
  table_for(Ticket, :url => {}, :partial => 'atickets', :id => 'a')
  table_for(Ticket, :url => {}, :partial => 'ctickets', :id => 'c')
  table_for(Blog,   :url => {}, :partial => 'blogs')

  ################################################################################
  def index
    @user = self.current_user
    @projects = @user.projects
  end

  ################################################################################
  def password
    @authenticator = Authenticator.fetch

    if request.post? and 
      @change_result = @authenticator.change_password(params, current_user.account_id)
      redirect_to(:action => 'index') if @change_result.respond_to?(:email)
    end
  end

end
################################################################################
