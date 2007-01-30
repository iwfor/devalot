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
class Page < ActiveRecord::Base
  ################################################################################
  attr_protected(:project_id)

  ################################################################################
  # Each page can have any number of tags
  acts_as_taggable

  ################################################################################
  validates_presence_of(:title)

  ################################################################################
  validates_uniqueness_of(:title, :scope => :project_id)

  ################################################################################
  # Each page belongs to a project
  belongs_to(:project)

  ################################################################################
  has_many(:comments, :as => :commentable)

  ################################################################################
  # Each page belongs to a FilteredText where the body is stored
  belongs_to(:filtered_text, :class_name => 'FilteredText', :foreign_key => :filtered_text_id)

  ################################################################################
  def self.find_by_title (title)
    if title.match(/^\d+$/)
      self.find_by_id(title)
    else
      self.find(:first, :conditions => {:title => title})
    end
  end

  ################################################################################
  # Use the page title as the ID
  def to_param
    self.title unless self.title.blank?
  end

end
################################################################################
