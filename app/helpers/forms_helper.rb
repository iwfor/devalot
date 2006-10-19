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
module FormsHelper
  ################################################################################
  class Generator
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::FormTagHelper

    ################################################################################
    def initialize (form_description)
      @form_description = form_description
    end

    ################################################################################
    def fields
      fields_str = ''

      @form_description.fields.each do |field|
        case field[:type]
        when :text
          inside_label(field, fields_str) do |str|
            str << text_field_tag(field[:attribute])
          end
        when :password
          inside_label(field, fields_str) do |str|
            str << password_field_tag(field[:attribute])
          end
        end
      end

      fields_str
    end

    ################################################################################
    def inside_label (field, str)
      str << %Q(<p><label for="#{field[:attribute]}">#{field[:label]}</label>)
      yield(str) if block_given?
      str << %Q(</p>\n)
    end

  end
end
################################################################################
