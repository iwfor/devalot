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
  module ExtendActionView
    ################################################################################
    # Generate a form for the given object (optional).  An
    # EasyForms::Description object is passed to the given block to configure
    # the fields of the form.
    def generate_form_for (object=nil, options={}, &block)
      desc = EasyForms::Description.new(object, options, &block)
      concat(generate_form_from(desc, options), block)
    end

    ################################################################################
    # Generate a form using an existing form description object.  See
    # generate_form_for for more details.
    def generate_form_from (desc, options={})
      configuration = {
        :id      => nil,
        :legend  => nil,
        :url     => {},
        :xhr     => false,
        :html    => {:multipart => true},
        :spinner => nil,

      }.update(options)

      result = generate_form_start(desc.for_object, configuration)
      result << %Q(<fieldset>)
      result << %Q(<legend>#{h(configuration[:legend])}</legend>) if configuration[:legend]
      result << generate_form_errors(desc)
      result << generate_form_fields(desc)
      result << generate_form_buttons(desc, configuration)
      result << %Q(</fieldset></form>)

      result
    end
    
    ################################################################################
    def generate_icon_form (source, options={})
      configuration = {
        :url              => {},
        :html             => {:class => 'icon_form'},
        :xhr              => false,
        :confirm          => nil,
        :force_no_spinner => true,
      }.update(options)

      result = generate_form_start(nil, configuration)
      result << image_submit_tag(source, configuration[:html])
      result << %Q(</form>)
      result
    end

    ################################################################################
    def generate_fast_form (options={})
      configuration = {
        :name      => 'fast_form',
        :value     => nil,
        :id        => nil,
        :class     => 'fast_form_field',
        :button    => 'Update',
        :action    => nil,
        :cancel    => nil,
        :label     => nil,
        :field     => :text,
        :url       => {},
        :effect    => :toggle_slide,
        :xhr       => true,
        :spinner   => nil,
        :fast_form => true,
        :html      => {},

      }.update(options)

      configuration[:url][:action] = configuration[:action] if configuration[:action]

      div_id = configuration[:id] ? configuration[:id] : generate_form_html_id(configuration)
      configuration[:id] = nil # so that we generate a new ID for the form element

      result  = %Q(<div id="#{div_id}" style="display:none;"><div class="fast_form">)
      result << generate_form_start(nil, configuration)
      result << %Q(<span class="fast_form_label">#{configuration[:label]}</span>) if configuration[:label]

      field_attributes = {
        :id => "#{configuration[:id]}_field",
        :class => configuration[:class],
      }

      case configuration[:field]
      when :text
        result << text_field_tag(configuration[:name], configuration[:value], field_attributes)
      end

      buttons = EasyForms::Description.new
      buttons.button(configuration[:button])

      if configuration[:cancel]
        action = lambda {|p| p << visual_effect(configuration[:effect], div_id)}
        buttons.button('Cancel', :do => action)
      end

      result << generate_form_buttons(buttons, configuration)
      result << %Q(</form></div></div>)
      result
    end

    ################################################################################
    def generate_form_errors (desc)
      form_errors = desc.form_errors
      obj_errors  = desc.form_objects.select {|o| !o.errors.blank?}.map {|o| o.errors.full_messages}.flatten
      return '' if form_errors.empty? and obj_errors.empty?

      result = %Q(<div class="error_messages">)

      form_errors.each do |message|
        result << %Q(<p>#{message}</p>)
      end

      if !obj_errors.empty?
        result << %Q(<p>Please correct the following problems:</p><ol>)

        obj_errors.each do |message|
          result << %Q(<li>#{message}</li>)
        end

        result << %Q(</ol>)
      end

      result << %Q(</div>)
      result
    end


    ################################################################################
    def generate_form_fields (form_description)
      form_description.fields.inject(String.new) do |str, field|
        # check the params for fields that should have a value set
        if field[:value].blank? and !params[field[:name]].blank?
          field[:value] = params[field[:name]]
        end

        case field[:type]
        when :text_field, :password_field, :text_area
          generate_para_with_label(field, str) do |str|
            str << self.send("#{field[:type]}_tag", field[:name], field[:value], field[:options])
          end
        when :check_box
          field[:class] = 'check_box_label' unless field[:class]

          generate_para_with_label(field, str) do |str|
            str << check_box_tag(field[:name], 1, field[:value], field[:options])
          end
        when :hidden_field
          str << hidden_field_tag(field[:name], field[:value], field[:options])
        when :collection_select
          field[:class] = 'select_label' unless field[:class]

          generate_para_with_label(field, str) do |str|
            str << %Q(<select name="#{field[:name]}">)
            str << options_for_select(field[:collection].map {|o| [o.send(field[:text_method]), o.send(field[:value_method])]}, field[:value])
            str << %Q(</select>)
          end
        when :file_field
          field[:class] = 'file_field_label' unless field[:class]

          generate_para_with_label(field, str) do |str|
            str << self.hidden_field_tag(field[:tmp_name], field[:value])
            str << self.file_field_tag(field[:name], field[:options])
          end
        when :form
          str << generate_sub_form(field)
        end
      end
    end

    ################################################################################
    def generate_form_buttons (form_description, options={})
      result = %Q(<div class="form_buttons"><div id="form_buttons_#{options[:id]}">)

      form_description.buttons.inject(result) do |str, button|
        if button[:name] == 'Cancel'
          if options[:xhr] and cancel_block = button[:options].delete(:do)
            str << button_to_function(button[:name], button[:options], &cancel_block)
          elsif cancel_url = button[:options].delete(:url)
            url = url_for(cancel_url)

            str << button_to_function(button[:name], button[:options]) do |page|
              page.redirect_to(url)
            end
          end
        else
          str << submit_tag(button[:name], button[:options])
        end
      end


      result << %Q(</div>)

      if options[:spinner]
        result << image_tag(options[:spinner], {
          :id    => "form_spinner_#{options[:id]}",
          :style => 'display: none;',
        })
      end

      result << %Q(<br class="clear"/></div>)
      result
    end

    ################################################################################
    def generate_para_with_label (field, str)
      css_class = field[:class]
      text = field[:label].sub(/(\(.+\))/, '<em>\1</em>')

      label  = %Q(<label for="#{field[:name]}")
      label << %Q(class="#{css_class}") if css_class
      label << %Q(>#{text}</label>)

      str << %Q(<p>)
      str << label unless field[:type] == :check_box
      yield(str) if block_given?
      str << label if field[:type] == :check_box
      str << %Q(</p>\n)
    end

    ################################################################################
    def generate_sub_form (field)
      result = ''

      legend  = field[:options][:legend]
      hidden  = field[:options][:hidden] || false
      form_id = field[:options][:id] || 'subform'

      # need a legend if hidden is set
      legend = 'Show Other Form' if hidden and legend.blank?

      form_str = generate_form_fields(field[:value])

      if !legend.blank?
        if hidden
          legend = link_to_function(legend) {|p| p << visual_effect(:toggle_slide, form_id)}
        end

        result << %Q(<fieldset><legend>#{legend}</legend>)
        result << %Q(<div id="#{form_id}" style="display: none;">) if hidden
        result << form_str
        result << %Q(</div>) if hidden
        result << %Q(</fieldset>)
      else
        result << form_str
      end

      result
    end

    ################################################################################
    def generate_form_start (object, options)
      # Give the application a chance to set global options
      self.easy_forms_options(options) if self.respond_to?(:easy_forms_options)

      # create an ID for this form
      options[:id] = generate_form_html_id(options) if options[:id].blank?

      result = ''
      on_submit = ""

      # must do confirm this way because of the spinner on_sumbit stuff
      if options[:confirm]
        on_submit << "if (!confirm('#{escape_javascript(options[:confirm])}')) {return false;};"
      end

      if options[:spinner] and !options[:force_no_spinner]
        on_submit << %Q(Element.hide($('form_buttons_#{options[:id]}'));)
        on_submit << %Q(Element.show($('form_spinner_#{options[:id]}'));)
        on_submit << %Q(true;)
      end

      if object
        unless options[:url][:action]
          options[:url][:action] = object.new_record? ? 'create' : 'update'
        end

        options[:url][:id] = object.to_param unless options[:url][:id]
        options[:html][:method] = object.new_record? ? :post : :put
      end

      form_options = {}
      form_options[:html] = options[:html] || {}
      form_options[:html][:class] = 'fast_form' if options[:fast_form]
      form_options[:html][:id] ||= "easy_form_#{options[:form_count]}"
      form_options[:html][:onsubmit] ||= ""

      if options[:xhr] or request.xhr?
        form_options[:url] = (options[:url] || {})
        form_options[:html][:onsubmit] << on_submit unless on_submit.blank?
        result << form_remote_tag(form_options)
      else
        form_options[:html][:onsubmit] << on_submit unless on_submit.blank?
        result << form_tag((options[:url] || {}), (form_options[:html] || {}))
      end
    end

    ################################################################################
    def generate_form_html_id (options)
      options[:form_count] = @controller.instance_variable_get(:@easy_forms_form_count) || 0
      options[:form_count] += 1
      @controller.instance_variable_set(:@easy_forms_form_count, options[:form_count])
      options[:form_count]
    end

  end
end
################################################################################
