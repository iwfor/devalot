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
module AuthHelper
  ################################################################################
  # Check to see if a remote web user has been authenticated
  def logged_in?
    !session[:user_id].nil?
  end

  ################################################################################
  # Get the User object for the logged in user
  def current_user
    return User.new unless logged_in?
    User.find(session[:user_id])
  end

  ################################################################################
  # Set the logged in user, or log the current user out
  def current_user= (user)
    reset_session unless user
    session[:user_id] = user ? user.id : nil
  end
  
  ################################################################################
  def authenticate
    user = current_user if logged_in?

    if !user
      session[:after_login] = request.request_uri
      redirect_to(:controller => 'account', :action => 'login')
      return nil
    end

    user
  end

  ################################################################################
  def authorize (*permissions)
    return false unless user = authenticate
    return true  if user.is_root?
    return false unless @project

    configuration = permissions.last.is_a?(Hash) ? permissions.pop : {}
    return true if current_user == configuration[:or_user_matches]

    permissions.each do |permission|
      return false unless user.send("#{permission}?", @project)
    end

    true
  end

end
################################################################################
