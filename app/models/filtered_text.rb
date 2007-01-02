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
class FilteredText < ActiveRecord::Base
  ################################################################################
  acts_as_versioned(:if_changed => [:body, :updated_by])

  ################################################################################
  attr_protected(:created_by, :updated_by)
  
  ################################################################################
  # Each page has a user that created the text, and another that changed it
  belongs_to(:created_by, :class_name => 'User', :foreign_key => :created_by_id)
  belongs_to(:updated_by, :class_name => 'User', :foreign_key => :updated_by_id)
  
  ################################################################################
  # ActiveRecord optimistic locking is neat, but a bit lame.  Make it more
  # useful by changing lock errors from exceptions to error messages that can
  # be displayed in forms, and put the lock_version field back to the value
  # before the save so that another save still fails.
  def save (*args)
    @lock_version_before_save = self.lock_version
    super
  rescue ActiveRecord::StaleObjectError
    message  = "Another user updated this text after you started your edit session "
    message << "but before you saved.  Please cancel this edit session and re-edit "
    message << "this text."
    self.errors.add_to_base(message)
    self.lock_version = @lock_version_before_save
    false
  end

end
################################################################################
