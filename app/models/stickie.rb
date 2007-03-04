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
class Stickie < ActiveRecord::Base
  ################################################################################
  MESSAGE_TYPES = %w(Notice Warning Error)

  ################################################################################
  attr_protected(:stickiepad_id, :stickiepad_type)

  ################################################################################
  validates_inclusion_of(:message_type, :in => MESSAGE_TYPES)

  ################################################################################
  belongs_to(:stickiepad, :polymorphic => true)

  ################################################################################
  belongs_to(:filtered_text)

  ################################################################################
  def self.find_for_user (user, include_system=true)
    conditions = [""]
    
    unless user.nil? or user.id.nil?
      conditions.first << "(stickiepad_type = ? and stickiepad_id = ?)"
      conditions << 'User'
      conditions << user.id
    end

    if include_system
      conditions.first << " OR" unless conditions.first.empty?
      conditions.first << " (stickiepad_type IS NULL AND stickiepad_id IS NULL)"
    end

    find(:all, :conditions => conditions)
  end

  ################################################################################
  private

  ################################################################################
  before_save do |stickie|
    stickie.filtered_text.allow_caching = true
  end

  ################################################################################
  after_destroy do |stickie|
    stickie.filtered_text.destroy
  end

end
################################################################################
