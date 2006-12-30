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
  # we don't work in the context of a project
  without_project

  ################################################################################
  before_filter(:fetch_authenticator)

  ################################################################################
  def login
    @form_description = EasyForms::Description.new
    @authenticator.form_for_login(@form_description)

    # when we don't have a place to go after login, and the HTTP_REFERER is
    # a URL from this application, go back to that URL after login
    # if session[:after_login].nil? and request.env['HTTP_REFERER']
    #   referer = URI.parse(request.env['HTTP_REFERER'])
    #   here    = URI.parse("http://#{request.env['HTTP_HOST']}")

    #   # kludge: HTTP_REFERER is from our site if it has the same host and port
    #   if "#{referer.host}:#{referer.port}" == "#{here.host}:#{here.port}"
    #     session[:after_login] = request.env['HTTP_REFERER']
    #   end
    # end

    if request.post? and account = @authenticator.authenticate(params) and account.respond_to?(:email)
      self.current_user = User.from_account(account)

      if session[:after_login]
        redirect_to(session[:after_login])
        session[:after_login] = nil
      else
        redirect_to(:controller => 'dashboard')
      end
    elsif request.post? and !account.nil?
      @form_description.error(account)
    end

  end

  ################################################################################
  def logout
    if self.current_user.account_id and @authenticator.respond_to?(:logout)
      @authenticator.logout(self.current_user.account_id)
    end

    self.current_user = nil
    redirect_to('/') # FIXME
  end

  ################################################################################
  private

  ################################################################################
  def fetch_authenticator
    @authenticator = Authenticator.fetch
  end

end
################################################################################
