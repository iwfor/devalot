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
class CommentTableHelper < TableMaker::Proxy
  ################################################################################
  include TimeFormater
  include PagesHelper
  include TicketsHelper

  ################################################################################
  columns(:only => [:commentable_type, :commentable, :filtered_text, :created_on])

  ################################################################################
  def heading_for_commentable_type
    "Item Type"
  end
  
  ################################################################################
  def heading_for_commentable
    "Item Title"
  end

  ################################################################################
  def display_value_for_commentable (comment)
    item = comment.commentable

    case item
    when Page
      link_to_page_object(item)
    when Ticket
      link_to_ticket(h(item.title), item)
    else
      [:title, :name].each {|m| break item.send(m) if item.respond_to?(m)}
    end
  end

  ################################################################################
  def heading_for_filtered_text
    "Excerpt"
  end

  ################################################################################
  def display_value_for_filtered_text (comment)
    h(truncate(comment.filtered_text.body))
  end

  ################################################################################
  def display_value_for_created_on (comment)
    format_time_from(comment.created_on, @controller.current_user)
  end

end
################################################################################
