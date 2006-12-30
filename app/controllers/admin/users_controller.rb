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
class Admin::UsersController < AdminController
  ################################################################################
  before_filter(:fetch_authenticator)

  ################################################################################
  def list
  end

  ################################################################################
  def new
  end
  
  ################################################################################
  def create
    @create_result = @authenticator.create_account(params, true)

    if @create_result.respond_to?(:email)
      user = User.from_account(@create_result)
      user.attributes = params[:user]
      user.is_root = !params[:user][:is_root].blank?
      user.save

      redirect_to(:action => 'list')
    else
      render(:action => 'new')
    end
  end

  ################################################################################
  private

  ################################################################################
  def fetch_authenticator
    @authenticator = Authenticator.fetch
  end

end
################################################################################
