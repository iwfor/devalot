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
module WatcherExtensions
  ##############################################################################
  # Return a list of users watching the current object.
  def users
    proxy_owner.watchers.find(:all, :include => :user).map(&:user)
  end

  ##############################################################################
  # Return a list of email recipients.
  def recipients
    proxy_owner.watchers.find(:all, :include => :user).map {|watcher| watcher.user.email}
  end

  ##############################################################################
  # Return a list of objects being watched by the current user.
  def objects
    proxy_owner.watching.find(:all, :include => :watchable).map {|watcher| watcher.watchable}
  end

  ##############################################################################
  def notify
    users.each do |user|
      WatchNotification.add(proxy_owner)
    end
  end

  ##############################################################################
  # Check whether the give user is watching the current object.
  def watching?(user)
    return nil unless user
    proxy_owner.watchers.find(:first, :conditions => { :user_id => user.id }) != nil
  end

  ##############################################################################
  # Toggle whether the given user is watching the current object, then report
  # the new state.
  def toggle(user)
    record = proxy_owner.watchers.find :first, :conditions => { :user_id => user.id }
    watching = record != nil
    if record
      record.destroy
    else
      proxy_owner.watchers.create :user_id => user.id
    end
    !watching
  end

end
