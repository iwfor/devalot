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
module HistoryExtensions
  ##############################################################################
  # Return a list of history entries for the current user.
  def get_user_changes
    proxy_owner.histories.find(:all, :include => :record)
  end

  ##############################################################################
  # Return a list of changes to the current record.
  def get_record_changes
    proxy_owner.histories.find(:all, :include => :user)
  end

  ##############################################################################
  # Create a history object and associated entries.
  def create_record(action, user = nil, changes = [])
    return unless History.write_history
    user_id = user.blank? ? nil : user.id
    history = proxy_owner.history.build(
      :project_id => proxy_owner.project_id,
      :user_id => user_id,
      :action => action
    )
    changes.each do |change|
      history.history_entries.build(
        :action     => change[:action],
        :field      => change[:field],
        :value      => change[:value].to_s,
        :value_type => change[:value].class.to_s
      )
    end
    history.save
  end
end
