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
    # all creation link if necessary
    return title unless page = Page.find_by_title(title)

    link_to(title, {
      :controller => 'pages',
      :action     => 'show',
      :id         => page,
      :project    => page.project,
    })
  end
  
  ################################################################################
  def page_body_as_html (page)
    # FIXME write a filtering library
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

    sanitize(RedCloth.new(body).to_html)
  end

end
################################################################################
