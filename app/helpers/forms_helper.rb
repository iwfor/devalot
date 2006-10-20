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
  # Generate a form for the given object (optional).  A FormDescription object is
  # passed to the given block to configure the fields of the form.
  def generate_form_for (object=nil, options={}, &block)
    desc = FormDescription.new(object)
    yield(desc)

    url = {}
    html_options = {}

    if object
      url[:action] = object.new_record? ? 'create' : 'update'
      url[:id] = object.to_param unless object.new_record?
      html_options[:method] = object.new_record? ? :post : :put
    end

    if request.xhr? or options[:xhr]
      concat(form_remote_tag(:url => url, :html => html_options), block)
    else
      concat(form_tag(url, html_options), block)
    end

    if legend = options.delete(:legend)
      concat(%Q(<legend>#{legend}</legend>), block)
    end

    concat(generate_form_fields(desc), block)
    concat(generate_form_buttons(desc), block)
    concat(end_form_tag(), block)
  end

  ################################################################################
  def generate_form_fields (form_description)
    form_description.fields.inject(String.new) do |str, field|
      case field[:type]
      when :text_field, :password_field, :text_area
        generate_para_with_label(field, str) do |str|
          str << self.send("#{field[:type]}_tag", field[:name], field[:value], field[:options])
        end
      when :collection_select
        generate_para_with_label(field, str) do |str|
          str << %Q(<select name="#{field[:name]}">)
          str << options_for_select(field[:collection].map {|o| [o.send(field[:text_method]), o.send(field[:value_method])]}, field[:value])
          str << %Q(</select>)
        end
      end
    end
  end

  ################################################################################
  def generate_form_buttons (form_description)
    form_description.buttons.inject(String.new) do |str, button|
      if cancel = button[:options].delete(:cancel)
        url = url_for(cancel)
        button[:options][:onclick] = update_page {|page| page.redirect_to(url)}
      end

      str << submit_tag(button[:name], button[:options])
    end
  end

  ################################################################################
  def generate_para_with_label (field, str)
    str << %Q(<p><label for="#{field[:name]}">#{field[:label]}</label>)
    yield(str) if block_given?
    str << %Q(</p>\n)
  end

end
################################################################################
