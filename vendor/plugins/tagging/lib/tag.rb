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
# A sigle tag in the database
class Tag < ActiveRecord::Base
  ################################################################################
  # A tag can be linked back to the objects that are using it
  has_many(:taggings, :order => 'created_on DESC', :dependent => :delete_all)

  ################################################################################
  # Parse a tag list, tags are separated with white space.  The code for
  # this method was extracted from the acts_as_taggable code by David
  # Heinemeier Hansson from this file:
  #
  # http://dev.rubyonrails.com/svn/rails/plugins/acts_as_taggable/lib/tag.rb
  #
  # The code on that site doesn't appear to have a license, so I assume it's
  # the MIT license (like this code, except copyright David Heinemeier
  # Hansson).
  def self.parse (list)
    tag_names = []

    # force tags to be lowercase
    list.downcase!

    # first, pull out the quoted tags
    list.gsub!(/\"(.*?)\"\s*/ ) {tag_names << $1; ""}

    # then, replace all commas with a space
    list.gsub!(/,/, " ")

    # then, get whatever's left
    tag_names.concat(list.split(/\s/))

    # strip whitespace from the names
    tag_names = tag_names.map {|t| t.strip}

    # delete any blank tag names
    tag_names = tag_names.delete_if {|t| t.empty?}

    tag_names
  end
  
  ################################################################################
  # Return all tags.  This is nice so that the Tag class can act like an
  # instance of a class that has acts_as_taggable set on it.  In other words,
  # it makes the tag cloud generator easier to write.
  def self.tags
    self.find(:all, :order => :name)
  end

  ################################################################################
  def self.find (*args)
    if args.length == 1 and args.first.is_a?(String)
      self.find_by_name(args.first) || super(*args)
    else
      super(*args)
    end
  end

  ################################################################################
  # Find the most often used tags
  def self.popular (limit=10)
    self.find(:all, :order => 'reference_count DESC', :limit => limit)
  end

  ################################################################################
  # Use the name of the tag instead of the id for links
  def to_param
    self.name.blank? ? self.id : self.name.to_param
  end

end
################################################################################
