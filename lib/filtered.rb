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
module Filtered
  ##############################################################################
  def self.render_filtered(object, field)
    filter_cache = object.send "#{field}_cache"
    return filter_cache if filter_cache
    body = object.send field
    filter = object.send "#{field}_filter"

    # Replace the following items
    #
    # 1. Wiki links that are surrounded by [[ and ]]
    # 2. References to tickets like 'ticket 1' or 'ticket #1'
    # 3. Escape references like 'ticket \1' and 'ticket #\1'
    #
    # See PagesHelper::link_to_page for what goes between [[ and ]]
    filtered_body = ''
    unless body.blank?
      filtered_body = body.gsub(/(?:\[\[([^\]]+)\]\]|\b(ticket|bug)\s#?(\\)?(\d+))/i) do |match|
        if match[0,2] == '[['
# XXX
#          link_to_page($1)
          $1
        elsif $3 == '\\'
          match.sub('\\', '')
        else
          link_to_ticket(match, $4)
        end
      end
    end

    # Run the text through a filter like Textile
    filtered_body = TextFilter.filter_with(filter, filtered_body)

    # Replace text that looks like links with links, avoiding real links
    filtered_body.gsub!(/(?:=")?([a-z]+:\/\/(?:[\w\/:;=&\?\.\-\#\+\%]+))/) do |match|
      if match[0,2] == '="'
        match
      else
        dollar_1 = $1.dup
        url = dollar_1.sub(/[\.\?]$/, '')
        ending = dollar_1.sub(url, '')
            %Q(<a href="#{url}">#{url}</a>#{ending})
      end
    end

    object.send("#{field}_cache=", filtered_body)
  end
end
