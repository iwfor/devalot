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
module TaggingPlugin
  ################################################################################
  # Helper class for generating tag clouds.  The code used in this class was
  # derived from a blog entry from Tom Fakes on October 28, 2005:
  # http://blog.craz8.com/articles/2005/10/28/acts_as_taggable-is-a-cool-piece-of-code
  class Cloud
    ################################################################################
    # Setup the tag cloud
    def initialize (tags, categories)
      @tags = tags
      @categories = categories
      @counts = @tags.sort {|a,b| a.reference_count <=> b.reference_count}
      @divisor = ((@counts.last.reference_count - @counts.first.reference_count) / @categories.size) + 1
    end

    ################################################################################
    # Iterate over all the tags, passing in their calculated category
    def tags_with_category (&block)
      @tags.each do |tag|
        yield(tag, @categories[(tag.reference_count - @counts.first.reference_count)/@divisor])
      end
    end

  end
end
################################################################################
