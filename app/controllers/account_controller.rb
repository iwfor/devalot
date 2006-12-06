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
class AccountController < ApplicationController
  ################################################################################
  # set which authenticator we should use
  @@authenticator = BuiltinAuthenticator
  cattr_accessor(:authenticator)

  ################################################################################
  # we don't work in the context of a project
  without_project

  ################################################################################
  def login
    @form_description = FormDescription.new
    @@authenticator.form_for_login(@form_description)

    # if we had a direct request from somewhere on the site, go back to that
    # page after we login
    if session[:after_login].nil? and request.env['HTTP_REFERER']
      # FIXME
      referer = URI.parse(request.env['HTTP_REFERER'])
      here    = URI.parse(request.request_url)

      [:path=, :fragment=, :query=].each {|m| referer.send(m, nil); here.send(m, nil)}
      session[:after_login] = request.env['HTTP_REFERER'] if referer == here
    end

    if request.post? and account = @@authenticator.authenticate(params)
      self.current_user = User.from_account(account)

      if session[:after_login]
        redirect_to(session[:after_login])
        session[:after_login] = nil
      else
        render(:text => "You're In #{current_user.inspect}") # FIXME redirect or do whatever
      end
    end
  end

  ################################################################################
  def logout
    self.current_user = nil
    redirect_to('/') # FIXME
  end

end
################################################################################
