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
  # The description for this change is actually an array of hashes.
  # This has been updated from the previews array of strings, but remains
  # backward compatible in the views.
  # Used hash fields are:
  #   :change => Type of change involved, either: new, edit, set, unset, comment
  #   :attribute => lower case name of attribute concerned (optional)
  #   :id => comment id (optional if not comment!)
  #   :title => Title of ticket (if new, used in Timeline)
  #   :from, :to => Values changed from and to respectively (optional)
  #   :comment => Additional info, changed data? (optional)
  serialize(:description, Array)

  ################################################################################
  # Always provide an array of strings, from the description.
  # This method us a bit wet (i.e. not DRY), and should be tidied, but until the
  # full timeline is complete, this version works quite well.
  def description_texts
    return self.description if self.description.first.is_a? String
    data = [ ]
    columns = Ticket.columns_hash
    self.description.each do | item |
      # perform some string preperations
      unless item[:attribute].blank?
        if item[:attribute] == 'state'
          item[:from] = Ticket.state_title_from_name( item[:from] )
          item[:to] = Ticket.state_title_from_name( item[:to] )
        end
        item[:attribute] = _( 'Ticket|'+item[:attribute].humanize ).gsub(/^.*\|/, '')
      end
      case item[:change].to_s
      when 'new'
        data << _("Ticket Created")
      when 'edit'
        if item[:from] and item[:to]
          data << ( _("%{attribute} changed from %{from} to %{to}") % item )
        else
          data << ( _("%{attribute} changed") % item )
        end
      when 'set'
        data << ( _("%{attribute} was set to %{to}") % item )
      when 'unset'
        data << ( _("%{attribute} was unset from %{from}") % item )
      when 'comment'
        data << ( _("Posted comment %{id}") % item )
      end
    end
    return data
  end
  
  ################################################################################
  # A comment was added to a ticket, record it
  def add_comment (comment)
    self.description = [ {:id => comment.id, :change => 'comment'} ]
    self.user = comment.user
  end

  ################################################################################
  # Does this history item reference a comment?
  def is_comment?
    entry = Array(self.description).first
    if entry.is_a? Hash
      c_id = entry[:id] if entry[:change] == 'comment'
    else
      # old version! Maintained for backwards compatability
      if m = entry.to_s.match(/^Posted comment (\d+)$/)
        c_id = m[1]
      end
    end
    unless c_id.blank?
      self.ticket.comments.find_by_id(m[1])
    end
  end
  
end
################################################################################
