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
        :layout  => EasyForms::StandardLayout,

      }.update(options)

      # Create the form layout helper
      if Class === configuration[:layout]
        configuration[:layout] = configuration[:layout].new
        configuration[:layout].instance_variable_set("@controller", @controller)
      end

      generate_form_start(desc.for_object, configuration, desc) do
        configuration[:layout].field_set(configuration[:legend]) do
          inner  = generate_form_errors(desc, configuration)
          inner << generate_form_fields(desc, configuration)
          inner << generate_form_buttons(desc, configuration)
        end
      end
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

      generate_form_start(nil, configuration) do
        image_submit_tag(source, configuration[:html])
      end
    end

    ################################################################################
    # FIXME: What a fucking mess
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
    def generate_form_errors (desc, options={})
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
    def generate_form_fields (form_description, options={})
      # shortcut
      layout = options[:layout]

      form_description.fields.inject(String.new) do |str, field|
        # check the params for fields that should have a value set
        # TODO: correctly map complex field names to params
        if field.value.blank? and !params[field.name].blank?
          field.value = params[field.name]
        end

        case field.field_type
        when :text_field, :password_field, :text_area
          str << layout.field(field) do
            self.send("#{field.field_type}_tag", field.name, field.value, field.options)
          end
        when :check_box
          field.css_class ||= 'check_box_label'
          str << layout.field(field) do
            check_box_tag(field.name, 1, field.value, field.options)
          end
        when :hidden_field
          str << layout.field(field) do
            hidden_field_tag(field.name, field.value, field.options)
          end
        when :select_field
          field.css_class ||= 'select_label'
          str << layout.field(field) do
            inner  = %Q(<select name="#{field.name}">)
            inner << options_for_select(field.collection.map {|o| [o.send(field.text_method), o.send(field.value_method)]}, field.value)
            inner << %Q(</select>)
          end
        when :file_field
          field.css_class ||= 'file_field_label'
          str << layout.field(field) do
            inner  = hidden_field_tag(field.tmp_name, field.value)
            inner << file_field_tag(field.name, field.options)
          end
        when :form
          str << generate_sub_form(field, options)
        when :raw
          if field.label.nil?
            str << field.value.call
          else
            str << layout.field(field, &field.value)
          end
        else
          raise "unknown form field type: #{field.field_type}"
        end
      end
    end

    ################################################################################
    def generate_form_buttons (form_description, options={})
      button_set_options = {
        :inner_id => options[:id], 
        :spinner  => options[:spinner],
      }

      options[:layout].button_set(button_set_options) do
        form_description.buttons.inject(String.new) do |str, button|
          str << options[:layout].button(button) {generate_form_button(button)}
        end
      end
    end

    ################################################################################
    # FIXME standardize on the button features
    def generate_form_button (button)
      if button[:name] == 'Cancel'
        if cancel_block = button[:options].delete(:do)
          button_to_function(button[:name], button[:options], &cancel_block)
        elsif cancel_url = button[:options].delete(:url)
          url = url_for(cancel_url)
          button_to_function(button[:name], button[:options]) {|p| p.redirect_to(url)}
        else
          submit_tag(button[:name], button[:options])
        end
      else
        submit_tag(button[:name], button[:options])
      end
    end

    ################################################################################
    # FIXME this needs to be refactored
    def generate_sub_form (field, options)
      result = ''

      legend  = field.options[:legend]
      hidden  = field.options[:hidden] || false
      form_id = field.options[:id] || 'subform'

      # need a legend if hidden is set
      legend = 'Show Other Form' if hidden and legend.blank?

      form_str = generate_form_fields(field.value, options)

      if !legend.blank?
        if hidden
          legend = link_to_function(legend) {|p| p << visual_effect(:toggle_slide, form_id)}
        end

        result << %Q(<fieldset><legend>#{legend}</legend>)
        result << %Q(<div id="#{form_id}" style="display:none;">) if hidden
        result << form_str
        result << %Q(</div>) if hidden
        result << %Q(</fieldset>)
      else
        result << form_str
      end

      result
    end

    ################################################################################
    def generate_form_start (object, options, desc=nil, &block)
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
        on_submit << %Q(Element.hide('form_buttons_#{options[:id]}');)
        on_submit << %Q(Element.show('form_spinner_#{options[:id]}');)
        on_submit << %Q(true;)
      end

      if object
        if Hash === options[:url]
          options[:url][:action] = object.new_record? ? 'create' : 'update' unless options[:url][:action]
          options[:url][:id] = object.to_param unless options[:url][:id]
        end

        options[:html][:method] ||= (object.new_record? ? :post : :put)
      end

      form_options = {}
      form_options[:html] = options[:html] || {}
      form_options[:html][:class] = 'fast_form' if options[:fast_form]
      form_options[:html][:id] ||= "easy_form_#{options[:form_count]}"

      unless on_submit.blank?
        form_options[:html][:onsubmit] ||= ""
        form_options[:html][:onsubmit] << on_submit
      end

      if options[:xhr] or request.xhr?
        form_options[:url] = (options[:url] || {})
        result << form_remote_tag(form_options)
      else
        result << form_tag((options[:url] || {}), (form_options[:html] || {}))
      end

      # insert the contents of the form
      if block_given?
        result << yield.to_s
        result << %Q(</form>)

        # Attempt to focus one of the fields
        if desc and field = desc.focus_field
          result << javascript_tag("$('#{field}').activate();")
        else
          result << javascript_tag("Form.focusFirstElement('#{form_options[:html][:id]}');")
        end
      end

      result
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
