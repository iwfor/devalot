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
module PagesHelper
  ################################################################################
  def link_to_page (title)
    page_id = title

    title.sub!(/^([^:]+):(.+)$/) do |match|
      page_id = $2
      $1
    end

    page = @project.pages.find_by_title(page_id)

    if page
      link_to(title, {
        :controller => 'pages',
        :action     => 'show',
        :id         => page,
        :project    => @project,
      })
    elsif current_user.can_create_pages?(@project)
      title + link_to('?', {
        :controller => 'pages',
        :action     => 'new',
        :id         => page_id,
        :project    => @project,
      })
    else
      title
    end
  end
  
  ################################################################################
  def page_body_as_html (page)
    body = page.body

    # Replace the following items
    #
    # 1. Wiki links that are surrounded by [[ and ]]
    # 2. References to tickets like 'ticket 1' or 'ticket #1'
    body.gsub!(/(?:\[\[([^\]]+)\]\]|\b(?:ticket|bug)\s*#?(\d+))/i) do |match|
      if match[0,2] == '[['
        link_to_page($1)
      else
        link_to_ticket(match, $2)
      end
    end

    sanitize(TextFilter.filter_with(page.filter, body))
  end

end
################################################################################
