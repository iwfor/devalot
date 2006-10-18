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
class BuiltinAuthenticator
  ################################################################################
  # Do we allow people to create their own accounts?
  @@allow_public_account_creation = true
  cattr_accessor(:allow_public_account_creation)

  ################################################################################
  def self.params_for_login
    [
      {:label => 'Username: (e-mail address)',  :field => :username},
      {:label => 'Password:',                   :field => :password},
    ]
  end

  ################################################################################
  def self.params_for_create
    return nil unless @@allow_public_account_creation

    [
      {:label => 'First Name:',                 :field => :first_name},
      {:label => 'Last Name:',                  :field => :last_name},
      {:label => 'E-mail Address:',             :field => :email},
      {:label => 'Password:',                   :field => :password},
      {:label => 'Confirm Password:',           :field => :password2},
    ]
  end

  ################################################################################
  def self.authenticate (params)
    params.assert_valid_keys(params_for_login.map {|p| p[:field]})
    Account.authenticate(params[:username], params[:password])
  end

  ################################################################################
  def self.create_account (params)
    params.assert_valid_keys(params_for_create.map {|p| p[:field]})
    # FIXME
  end

end
################################################################################
