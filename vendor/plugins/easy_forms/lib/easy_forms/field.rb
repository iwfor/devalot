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
  # The EasyForms::Field class is used to store information about a single
  # form field.  It is used internally, but may be useful to others.
  class Field
    ################################################################################
    # A list of supported form fields
    FIELD_TYPES = [
      :text_field,
      :password_field,
      :text_area,
      :check_box,
      :hidden_field,
      :select_field,
      :file_field,
      :form,
      :raw,
    ]

    ################################################################################
    # Field attributes
    attr_accessor(:field_type)
    attr_accessor(:name)
    attr_accessor(:value)
    attr_accessor(:label)
    attr_accessor(:tmp_name)
    attr_accessor(:options)
    attr_accessor(:collection)
    attr_accessor(:value_method)
    attr_accessor(:text_method)
    attr_accessor(:css_class)
    attr_accessor(:focus)

    ################################################################################
    # Create a new field, and quickly setup its attributes
    def initialize (field_type, attributes={})
      unless FIELD_TYPES.include?(field_type)
        raise "bad field type: #{field_type}"
      end

      @options = {}
      @focus = false
      @field_type = field_type
      attributes.keys.each {|k| self.send("#{k}=", attributes[k])}
    end

    ################################################################################
    # Get the HTML ID attribute for this field
    def id
      @options[:id] || self.name
    end

    ################################################################################
    # Set the HTML ID attribute for this field
    def id= (id)
      @options[:id] = id
    end

    ################################################################################
    # Set the field name and tmp_name
    def name= (name)
      @name = name
      @tmp_name = @name.to_s + '_tmp'
      @options[:id] ||= @name
    end

    ################################################################################
    # Should this field receive the keyboard focus?
    def focus?
      @focus == true
    end

    ################################################################################
    # Markup the field label as HTML
    def label_as_html
      @label.to_s.sub(/(\(.+\))/, '<em>\1</em>')
    end

    ################################################################################
    # Add helper methods for checking the field_type
    FIELD_TYPES.each do |type|
      class_eval("def #{type}? () @field_type == :#{type} end")
    end

  end
end
################################################################################
