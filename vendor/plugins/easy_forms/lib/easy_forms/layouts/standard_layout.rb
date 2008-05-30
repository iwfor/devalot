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
module EasyForms
  ################################################################################
  # The EasyForms::StandardLayout class generates the HTML that wrapes the
  # form and form fields.
  class StandardLayout < ActionView::Base
    ################################################################################
    # The top most level of a form, all fields go inside the field_set.
    def field_set (legend=nil, &block)
      html  = %Q(<fieldset>)
      html << %Q(<legend>#{legend}</legend>) if legend
      html << yield.to_s
      html << %Q(</fieldset>)
    end

    ################################################################################
    # Add a new field to the form HTML
    def field (field, &block)
      # We don't need any additional markup for hidden fields
      return yield.to_s if field.hidden_field?

      # Build a label
      label  = %Q(<label for="#{field.id}")
      label << %Q(class="#{field.css_class}") if field.css_class
      label << %Q(>#{field.label_as_html}</label>)

      # Slam the whole thing together
      html  = %Q(\n<p>)
      html << label unless field.check_box?
      html << yield.to_s
      html << label if field.check_box?
      html << %Q(</p>\n)
    end

    ################################################################################
    # All buttons go into a button_set.  Options include:
    #
    # * +:inner_id+: The HTML ID suffix for a inner div
    # * +:class+: The HTML class and ID prefix for the divs
    # * +:spinner+: Include a spinner graphic for when buttons are hidden
    def button_set (options={}, &block)
      config = {
        :inner_id => '1',
        :class    => 'form_buttons',
        :spinner  => nil,
      }.update(options)

      html  = %Q(<div class="#{config[:class]}">)
      html << %Q(<div id="#{config[:class]}_#{config[:inner_id]}">\n)
      html << yield.to_s
      html << %Q(</div>)

      if config[:spinner]
        html << image_tag(config[:spinner], {
          :id    => "form_spinner_#{config[:inner_id]}",
          :style => 'display:none;',
        })
      end

      html << %Q(<br style="clear:both;"/>)
      html << %Q(</div>\n)
    end

    ################################################################################
    # Add a button to the button set
    def button (button, &block)
      yield.to_s + "\n"
    end

  end
end
################################################################################
