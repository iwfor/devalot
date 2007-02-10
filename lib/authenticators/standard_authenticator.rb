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
class StandardAuthenticator < Authenticator
  ################################################################################
  # Return an EasyForms::Description object that describes the login form
  def self.form_for_login (form)
    form.text_field(:username, 'Username: (e-mail address)')
    form.password_field(:password, 'Password:')
  end

  ################################################################################
  # Return an EasyForms::Description object that describes the new user
  # creation form, if users are allowed to create accounts.  Return nil, or
  # don't define this method if this authenticator doesn't support account
  # creation.
  def self.form_for_create (form)
    account_form(form, true)
  end

  ################################################################################
  # FIXME document
  def self.form_for_edit (form, account_id)
    account = Account.find(account_id)
    edit_form = EasyForms::Description.new(account)
    account_form(edit_form, false)
    form.subform(edit_form)
  end
  
  ################################################################################
  # FIXME document
  def self.form_for_change_password (form)
    form.password_field(:old_password, "Current Password:")
    form.password_field(:password, "New Password:")
    form.password_field(:password2, "Confirm New Password:")
  end

  ################################################################################
  # FIXME document
  def self.form_for_confirmation (form)
    error_message  = "Your account has been created, and a confirmation email has been sent.  "
    error_message << "Please check your email for instructions on how to activate your account."

    form.error(error_message)
    form.subform(activation_form)
  end

  ################################################################################
  # Given the fields from the login form, return an account object if the user
  # should be allowed to login, and an error message otherwise.  The object
  # returned upon successful authentication MUST respond to these messages:
  #
  # * id - The account ID for this user
  # * email - The email address for this user
  # * first_name - The first (given) name for this user
  # * last_name - The last (family) name for this user
  #
  def self.authenticate (params)
    if account = Account.authenticate(params[:username], params[:password]) and account.enabled?
      account
    elsif account.nil?
      "The user-name or password you entered is not correct"
    elsif account.require_activation?
      "Your account is awaiting confirmation"
    elsif !account.enabled?
      "Your account has been disabled"
    end
  end

  ################################################################################
  # Create an account from the form params from the form_for_create method.
  # You should return a string (or an array of strings) that is presented to
  # the user, or an account object if the user is allowed to login
  # immediately.
  #
  # If the from_admin parameter is true, the account creation is being done by
  # an administrator and therefore you shouldn't require any post-creation
  # steps such as account activation.
  #
  # When account confirmation is necessary, the URL given in confirm_url can
  # be given to a user (e.g. in an email) to confirm an account.
  def self.create_account (params, from_admin, confirm_url=nil)
    unless params[:password] == params[:password2]
      return "Password and password confirmation don't match"
    end

    account = Account.new(params)
    account.password = params[:password]
    saved = false

    if from_admin
      account.enabled = true
      saved = account.save
    else
      account.require_activation!
      saved = account.save
      BotMailer.deliver_activation_notice(account, confirm_url) if saved and confirm_url
    end

    saved ? account : account.errors.full_messages
  end

  ################################################################################
  # FIXME document
  def self.confirm_account (params)
    account = Account.activate(params[:username], params[:code])

    if account.nil?
      "There was a problem confirming your account.  Please check your email address and code and try again."
    else
      account.save!
      account
    end
  end

  ################################################################################
  # FIXME document
  def self.edit_account (params, account_id)
    account = Account.find(account_id)
    account.attributes = params[:account]
    account.save ? account : account.errors.full_messages
  end

  ################################################################################
  # FIXME document
  def self.change_password (params, account_id)
    account = Account.find(account_id)

    unless account.password?(params[:old_password])
      return "The password you entered for your current password is not correct"
    end

    unless params[:password] == params[:password2]
      return "Your new password and new password confirmation don't match"
    end

    account.password = params[:password]
    account.save ? account : account.errors.full_messages
  end

  ################################################################################
  # FIXME document
  def logout (account_id)
  end

  ################################################################################
  protected

  ################################################################################
  def self.account_form (form, include_password)
    form.text_field(:first_name, 'First Name:')
    form.text_field(:last_name, 'Last Name:')
    form.text_field(:email, 'E-mail Address:')

    if include_password
      form.password_field(:password, 'Password:')
      form.password_field(:password2, 'Confirm Password:')
    end
  end

  ################################################################################
  def self.activation_form
    EasyForms::Description.new do |f|
      f.text_field(:username, 'Email Address:')
      f.text_field(:code, 'Activation Code:')
    end
  end

end
################################################################################
