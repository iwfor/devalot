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
class Ticket < ActiveRecord::Base
  ################################################################################
  # validations
  validates_presence_of(:title, :summary)
  
  ################################################################################
  belongs_to(:project)
  belongs_to(:state)
  belongs_to(:severity)
  belongs_to(:priority)

  ################################################################################
  # This ticket may be marked as a duplicate of another ticket
  belongs_to(:duplicate_of, :class_name => 'Ticket', :foreign_key => 'duplicate_of')
  has_many(:duplicates,     :class_name => 'Ticket', :foreign_key => 'duplicate_of')

  ################################################################################
  # This ticket may be in a hierarchy
  belongs_to(:parent, :class_name => 'Ticket', :foreign_key => 'parent_id')
  has_many(:children, :class_name => 'Ticket', :foreign_key => 'parent_id')

  ################################################################################
  # There is one wiki page that is the summary of this ticket
  belongs_to(:summary, :class_name => 'Page', :foreign_key => 'summary_id')

end
################################################################################
