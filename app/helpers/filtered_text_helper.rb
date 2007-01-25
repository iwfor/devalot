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
module FilteredTextHelper
  ################################################################################
  def render_filtered_text (filtered_text, options={})
    configuration = {
      :radius => true,

    }.update(options)

    if filtered_text.allow_caching? and filtered_text.body_cache
      return filtered_text.body_cache
    end

    body = filtered_text.body

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

    filtered_body = TextFilter.filter_with(filtered_text.filter, body)

    if configuration[:radius]
      context = ProjectContext.new(@project, self)
      parser = Radius::Parser.new(context, :tag_prefix => 'r')
      filtered_body = parser.parse(filtered_body)
    end

    filtered_body = sanitize(filtered_body)

    if filtered_text.allow_caching?
      filtered_text.body_cache = filtered_body
      filtered_text.save
    end

    filtered_body
  end

  ################################################################################
  def filtered_text_form (filtered_text, body_label='Body', options={})
    configuration = {
      :prefix => nil,
    }.update(options)

    filtered_text ||= FilteredText.new

    EasyForms::Description.new(filtered_text, configuration) do |form|
      form.text_area(:body, "#{body_label}:")
      form.collection_select(:filter, "Filter:", TextFilter.list, :to_s, :to_s)
    end
  end

end
################################################################################
