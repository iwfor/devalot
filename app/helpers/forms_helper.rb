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
  # generate an HTML form
  class Generator
    include ActionView::Helpers::TagHelper
    include ActionView::Helpers::FormTagHelper
    include ActionView::Helpers::FormOptionsHelper

    ################################################################################
    def initialize (form_description)
      @form_description = form_description
    end

    ################################################################################
    def fields
      fields_str = ''

      @form_description.fields.each do |field|
        case field[:type]
        when :text_field, :password_field, :text_area
          inside_label(field, fields_str) do |str|
            str << self.send("#{field[:type]}_tag", field[:name], field[:value], field[:options])
          end
        when :collection_select
          inside_label(field, fields_str) do |str|
            str << %Q(<select name="#{field[:name]}">)
            str << options_for_select(field[:collection].map {|o| [o.send(field[:text_method]), o.send(field[:value_method])]}, field[:value])
            str << %Q(</select>)
          end
        end
      end

      fields_str
    end

    ################################################################################
    def inside_label (field, str)
      str << %Q(<p><label for="#{field[:name]}">#{field[:label]}</label>)
      yield(str) if block_given?
      str << %Q(</p>\n)
    end

  end
  
  ################################################################################
  # Generate a form for the given object (optional).  A FormDescription object is
  # passed to the given block to configure the fields of the form.
  def generate_form_for (object=nil, options={}, &block)
    desc = FormDescription.new(object)
    yield(desc)
    concat(Generator.new(desc).fields, block.binding)
  end
end
################################################################################
