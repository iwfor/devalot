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
class Attachment < ActiveRecord::Base
  ################################################################################
  # Attributes that can't be set from the form
  attr_protected(:project_id, :user_id, :public)

  ################################################################################
  # Any other model can have many attachments
  belongs_to(:attachable, :polymorphic => true)

  ################################################################################
  # Project to use for access rights
  belongs_to(:project)

  ################################################################################
  # Attachment Owner
  belongs_to(:user)
  
  ################################################################################
  # The actual attachments are kept on the file system
  file_column(:filename, :root_path => File.join(RAILS_ROOT, "attachments"))

  ################################################################################
  # Can the given user download the attachment?
  def can_download? (user)
    return true if self.public? 
    return user.projects.include?(self.project)
  end

end
################################################################################
