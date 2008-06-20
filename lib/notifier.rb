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
class Notifier < ActionMailer::Base
  
  ################################################################################
  # Load some important helpers
  helper(:application)  
  helper(:filtered_text)
  helper(:attachments)
  helper(:pages)
  helper(:tickets)
  helper(:people)
  
  ################################################################################
  # Send a single notification email based on the timeline entry 
  # and user object provided
  #
  # TODO Add support for users preferred language, or at least default to english.
  #
  def timeline_entry_for_ticket( entry, user )
    recipients user.email
    from Policy.lookup(:bot_from_email).value
    
    subject entry.full_title
    
    body :user => user, :entry => entry, :ticket => entry.parent
  end

end
