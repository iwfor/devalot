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
# This class is used by the built-in authenticator
class Account < ActiveRecord::Base
  ################################################################################
  attr_accessible(:first_name, :last_name, :email)

  ################################################################################
  validates_presence_of(:first_name, :last_name, :email)

  ################################################################################
  validates_uniqueness_of(:email)
  validates_format_of(:email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i)
  
  ################################################################################
  # Locate an account given an email address
  def find_by_email (email)
    self.find(:first, :conditions => {:email => email.downcase.strip})
  end

  ################################################################################
  # Locate the account with these credentials
  def self.authenticate (email, plain_password)
    if account = self.find_by_email(email) and account.password?(plain_password)
      account.reset_code = ''
      account.save

      account
    end
  end

  ################################################################################
  # Locate the given account and activate it
  def self.activate (code)
    if account = self.find(:first, :conditions => {:activation_code => code.upcase.strip})
      account.enabled = true
      account.activation_code = ''

      account
    end
  end

  ################################################################################
  def self.with_reset_code (code)
    if account.find(:first, :conditions => {:reset_code => code.upcase.strip})
      account.reset_code = ''
      account.save

      account
    end
  end
  ################################################################################
  # Validate this account, called by valid?
  def validate
    if @password_valid == false # only false when password= has been called
      self.errors.add_to_base("Please use a password that is at least 6 characters")
    elsif self.password_hash.blank?
      self.errors.add_to_base("Password can't be blank")
    end
  end

  ################################################################################
  # Check to see if the given clear text password matches the encryped one
  def password? (plain_password)
    self.class.mkpasswd(plain_password, self.password_salt) == self.password_hash
  end

  ################################################################################
  # Set the password for this account
  def password= (plain)
    return unless @password_valid = (!plain.blank? and plain.length > 5)
    self.password_salt = self.class.mksalt
    self.password_hash = self.class.mkpasswd(plain, self.password_salt)
  end

  ################################################################################
  # Force email address to be lowercase
  def email= (email)
    self[:email] = email.downcase.strip
  end

  ################################################################################
  # Require that the given account be activated with a code
  def require_activation!
    self.enabled = false
    self.activation_code = Digest::MD5.hexdigest(self.object_id.to_s + self.class.mksalt).upcase
  end
  
  ################################################################################
  # Check to see if this account requires activation
  def require_activation?
    !self.enabled? and !self.activation_code.blank?
  end

  ################################################################################
  # Create a password reset code for this account
  def reset_code!
    self.reset_code = Digest::MD5.hexdigest(self.object_id.to_s + self.class.mksalt).upcase
  end

  ################################################################################
  protected 

  ################################################################################
  def self.mkpasswd (plain, salt)
    Digest::SHA256.hexdigest(plain + salt)
  end

  ################################################################################
  def self.mksalt
    [Array.new(6) {rand(256).chr}.join].pack('m').chomp
  end

end
################################################################################
