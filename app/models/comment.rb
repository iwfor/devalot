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
class Comment < ActiveRecord::Base
  ################################################################################
  attr_protected(:commentable_id, :commentable_type, :user_id, :filtered_text_id)

  ################################################################################
  belongs_to(:commentable, :polymorphic => true, :counter_cache => true)

  ################################################################################
  belongs_to(:user)

  ################################################################################
  belongs_to(:filtered_text)

  ################################################################################
  private

  ################################################################################
  before_create do |comment|
    comment.visible = comment.user.has_visible_content?
    comment.filtered_text.created_by = comment.user
    comment.filtered_text.updated_by = comment.user
    comment.filtered_text.allow_caching = true
  end

end
################################################################################
