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
class AttachmentTableHelper < TableMaker::Helper
  ################################################################################
  include TimeFormater
  include PeopleHelper

  ################################################################################
  columns(:only => [:filename, :user, :public, :created_on])

  ################################################################################
  sort(:user, :include => :user, :asc => 'users.first_name, users.last_name', :desc => 'users.first_name DESC, users.last_name DESC')

  ################################################################################
  def heading_for_user
    "Owner"
  end

  ################################################################################
  def display_value_for_user (attachment)
    link_to_person(attachment.user)
  end

  ################################################################################
  def display_value_for_filename (attachment)
    title = h(File.basename(attachment.filename))
    
    if attachment.can_download?(@controller.current_user)
      title = link_to(title, {
        :controller => 'attachments', 
        :action     => 'download', 
        :id         => attachment, 
        :project    => attachment.project,
      })
    end

    title
  end

  ################################################################################
  def display_value_for_public (attachment)
    attachment.public? ? 'Yes' : 'No'
  end

  ################################################################################
  def display_value_for_created_on (attachment)
    h(format_time_from(attachment.created_on, @controller.current_user))
  end

end
################################################################################
