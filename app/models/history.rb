################################################################################
#
# Copyright (C) 2008 Isaac Foraker <isaac at noscience dot net>
# Copyright (C) 2006-2007 pmade inc. (Peter Jones <pjones at pmade dot com>)
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
# A History entry records when an associated model was modified.  The specific
# fields modified in the model are recorded in the history_entries.
class History < ActiveRecord::Base
  ##############################################################################
  # Control whether history is written.  Intended for use in migrations that
  # translate tables.
  @@write_history = true

  ##############################################################################
  # Associations
  has_many :history_entries, :dependent => :delete_all
  belongs_to :user
  # A history object can reference virtually any other model object in the
  # system as long as that model belongs to a project.
  belongs_to :record, :polymorphic => true

  ##############################################################################
  def self.write_history
    @@write_history
  end

  ##############################################################################
  def self.write_history=(value)
    @@write_history = value
  end
end
