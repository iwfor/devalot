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
class Article < ActiveRecord::Base
  ################################################################################
  # Must have a title
  validates_presence_of(:title)

  ################################################################################
  # What blog did this come from?
  belongs_to(:blog)

  ################################################################################
  # The author of the article
  belongs_to(:user)

  ################################################################################
  belongs_to(:body,    :class_name => 'FilteredText', :foreign_key => :body_id)
  belongs_to(:excerpt, :class_name => 'FilteredText', :foreign_key => :excerpt_id)

  ################################################################################
  acts_as_taggable

  ################################################################################
  # Mark the article as published
  def publish
    self.published = true
    self.published_on = Time.now
  end

end
################################################################################
