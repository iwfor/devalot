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
class TicketHistory < ActiveRecord::Base
  ################################################################################
  # Link back to our ticket
  belongs_to(:ticket)
  
  ################################################################################
  # The user that created this ticket change
  belongs_to(:user)

  ################################################################################
  # The description for this change is actually an array of strings
  serialize(:description, Array)

  ################################################################################
  # A comment was added to a ticket, record it
  def add_comment (comment)
    self.description ||= []
    self.description << "Posted comment #{comment.id}"
    self.user = comment.user
  end

  ################################################################################
  # Does this history item reference a comment?
  def has_comment?
    if m = Array(self.description).first.to_s.match(/^Posted comment (\d+)$/)
      self.ticket.comments.find_by_id(m[1])
    end
  end
  
end
################################################################################
