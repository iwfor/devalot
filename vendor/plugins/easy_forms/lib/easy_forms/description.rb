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
  # Help describe a form outside of a view
  class Description
    ################################################################################
    # Access the data about the fields in this form
    attr_reader :fields

    ################################################################################
    # Access the data about the buttons in this form
    attr_reader :buttons

    ################################################################################
    # Access to manual error messages
    attr_reader :errors
 
    ################################################################################
    # Access the object for this form (see also form_objects)
    attr_reader :for_object

    ################################################################################
    # The field to focus after the form is drawn
    attr_accessor(:focus_field)

    ################################################################################
    # Create a new form description object, optionally for the given object
    def initialize (for_object=nil, options={})
      @options = {
        :prefix => nil,

      }.update(options)

      @for_object = for_object
      @focus_field = nil
      @fields = []
      @buttons = []
      @errors = []

      if @for_object and @options[:prefix].nil?
        @options[:prefix] = @for_object.class.to_s.underscore.sub(/^.*\//, '')
      end

      yield(self) if block_given?

      # record the current locking version for optimistic locking
      if for_object and for_object.locking_enabled?
        hidden_field(for_object.class.locking_column.to_sym)
      end
    end

    ################################################################################
    # Return the prefix used while generating form element names
    def prefix
      @options[:prefix]
    end

    ################################################################################
    # Set the prefix used while generating form element names
    def prefix= (prefix)
      @options[:prefix] = prefix
    end

    ################################################################################
    # Create a text field
    #
    # * <tt>attribute</tt> - The object attribute, or name for the field.
    # * <tt>label</tt> - The text that goes inside the label HTML tag.
    # * <tt>options</tt> - A hash that is passed to text_field_tag.
    #
    def text_field (attribute, label, options={})
      field(:text_field, attribute, label, options)
    end

    ################################################################################
    # Create a password field.  See the text_field method for documentation.
    def password_field (attribute, label, options={})
      field(:password_field, attribute, label, options)
    end

    ################################################################################
    # Create a text area field.  See the text_field method for documentation
    def text_area (attribute, label, options={})
      field(:text_area, attribute, label, {:size => '80x20'}.merge(options))
    end

    ################################################################################
    # Create a check box field.
    def check_box (attribute, label, options={})
      field(:check_box, attribute, label, options)
    end

    ################################################################################
    # Create a hidden field
    def hidden_field (attribute, options={})
      field(:hidden_field, attribute, nil, options)
    end

    ################################################################################
    # Works like the ActionView collection_select, but uses the object given to the
    # initialize method instead of an instance variable.
    def collection_select (attribute, label, collection, value_method, text_method, options={})
      @fields << Field.new(:select_field, {
        :name         => field_name(attribute),
        :value        => field_value(attribute),
        :label        => label,
        :collection   => collection,
        :value_method => value_method,
        :text_method  => text_method,
        :options      => options,
      })

      self
    end

    ################################################################################
    def time_zone_select (attribute, priority_zones=nil, options={}, model=TimeZone)
      zones = model.all

      if priority_zones
        zones = priority_zones + zones.reject {|z| priority_zones.include?(z)}
      end

      collection_select(attribute, 'Time Zone:', zones, :name, :to_s, options)
    end

    ################################################################################
    # File upload fields
    def file_field (attribute, label, options={})
      field(:file_field, attribute, label, options)
    end

    ################################################################################
    # Adds a new grouping of form items to the form
    def subform (form_description=nil, options={}, &block)
      configuration = {
        :legend => nil,
        :hidden => false,

      }.update(options)

      if !form_description.nil? and !(self.class === form_description)
        form_description = self.class.new(object = form_description)
        form_description.prefix << "[#{object.id}]"
      end
      
      form_description ||= self.class.new
      yield(form_description) if block_given?

      @fields << Field.new(:form, {
        :value   => form_description, 
        :options => configuration,
      })

      form_description
    end

    ################################################################################
    # Insert raw HTML at this point in the form.  If you give a label, it will
    # be wrapped like other form elements, otherwise the HTML will be injected
    # onto the document without any special treatment.
    def raw (label=nil, &block)
      @fields << Field.new(:raw, :label => label, :value => block)
      self
    end

    ################################################################################
    # Adds a button to the form
    # FIXME we should have a button class
    def button (name, options={})
      @buttons << {:name => name, :options => options}
    end

    ################################################################################
    # Adds an error message that will show up on the form, can be an array of
    # error messages.
    def error (message)
      message.is_a?(Array) ? @errors.concat(message) : @errors.push(message)
    end

    ################################################################################
    # Get a list of all the objects (from this form and subforms)
    def form_objects
      objects = []
      objects << @for_object if @for_object
      objects + @fields.select {|f| f.form?}.map {|f| f.value.form_objects}.flatten
    end

    ################################################################################
    # Get a list of non-object form errors
    def form_errors
      @errors + @fields.select {|f| f.form?}.map {|f| f.value.form_errors}.flatten
    end

    ################################################################################
    protected

    ################################################################################
    def field (type, attribute, label, options)
     @fields << Field.new(type, {
        :name     => field_name(attribute), 
        :value    => field_value(attribute),
        :label    => label, 
        :options  => options
      })

      self
    end

    ################################################################################
    def field_name (attribute)
      if @options[:prefix]
        "#{@options[:prefix]}[#{attribute}]"
      else
        attribute
      end
    end

    ################################################################################
    def field_value (attribute)
      @for_object ? @for_object.send(attribute) : nil
    end

  end
end
################################################################################
