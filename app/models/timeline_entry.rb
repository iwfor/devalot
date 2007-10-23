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
#
# TimelineEntry - Created by Sam Lown <dev@samlown.com> 2007-09-10
# 
# Record changes made to page, blog, and ticket entries stored with 
# Devalot.
# 
# A Hash is used for the main description, as this allows greater details
# to be stored about the change, but principally allows for storage of the
# meaning of the update such that internationalisation can be correctly 
# applied. This of course makes the system a bit more complicated as 
# the views and presentation layers must understand more of the meaning
# of the message. It also screws up searching, but I'm hopeing this will
# not be something people will need. (Searching on so many possible values
# would be difficult anyway.)
# 
# Care must be taken when logging new forms of data as the views will need
# to be checked/updated to ensure the data will be displayed correctly.
#
class TimelineEntry < ActiveRecord::Base
  
  ################################################################################
  # Project that this TimelineEntry belongs to.
  # This is redundant, as the same information should be stored in the parent
  # object, however it is very useful for filtering.
  belongs_to :project
  
  ################################################################################
  # The polymorphic parent object where the changes were made.
  # This should be one of the SUPPORTED_PARENTS
  belongs_to :parent, :polymorphic => true

  ################################################################################
  # User who made the change
  belongs_to :user
  
  ################################################################################
  # Update this as more entries are to be logged.
  SUPPORTED_PARENTS = [ Ticket, Page, Article ]
  
  ################################################################################
  # The basic changes which will be accepted. Items in the description array
  # describe the real details of the change
  VALID_CHANGES = {
    :created => _('created'),
    :edited => _('edited'),
    :deleted => _('deleted'), # not sure delete is very useful!
    :closed => _('closed'),
    # :reopened => _('re-opened'),
  }
  
  ################################################################################
  # The description for this change is actually an array of hashes.
  # This has been updated from the previews array of strings, but remains
  # backward compatible in the views.
  # 
  # This format is similar and compatible with the hash used in the ticket 
  # history, although may contain further information should it be nessary.
  # 
  # We list the fields here so that we know what to expect in the views.
  # 
  # Used hash fields are:
  #  
  #  * :change => specific change made to the attribute, not to be confused
  #  with the type of change the timeline entry represents!
  #  * :attribute => lower case name of attribute concerned (optional)
  #  * :id => optional, may be useful for linking and has significance depending
  # on the parent
  #  * :title => Title of ticket (if new, used in Timeline)
  #  * :from, :to => Values changed from and to respectively (optional)
  #  * :comment => Additional info, changed data? (optional)
  #
  serialize(:description, Array)
  
  ################################################################################
  # Create an alias to the old parent setting method, then replace it with 
  # a version that will ensure the type is acceted.
  # (It appears super does not work here.)
  alias :parent_unsafe= :parent=
  
  def parent=( parent )
    if ! SUPPORTED_PARENTS.include? parent.class
      raise "Invalid or not supported parent object set for TimeLineEntry!"
    end
    self.parent_unsafe =  parent
  end

  ################################################################################
  # Set the change value and ensure it is one of the valid changes available.
  # Invalid changes are considered programing errors!
  def change=( change )
    raise "Invalid change provided!" if ! VALID_CHANGES.keys.include? change.to_sym
    super( change.to_s )
  end
  
  ################################################################################
  #
  def change
    super.to_sym
  end
  
  ################################################################################  
  def change_name
    VALID_CHANGES[ self.change ]
  end
 
  ################################################################################
  # Provide the valid changes constant
  def self.valid_changes
    VALID_CHANGES
  end
  
  ################################################################################
  # Special Truncate method to be used only for entries in the timeline.
  # The normal Rails truncate method is not easily available for models
  # and controllers, so we cheat (and provide no options).
  def self.truncate( text )
    text.chars.length > 250 ? text.chars[0...250] + "..." : text
  end
end
