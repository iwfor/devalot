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
# Help describe a form outside of a view
class FormDescription
  ################################################################################
  # access the data about the fields in this form
  attr_reader :fields

  ################################################################################
  # Create a new form description object, optionally for the given object
  def initialize (for_object=nil)
    @for_object = for_object
    @fields = []
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
  # Works like the ActionView collection_select, but uses the object given to the
  # initialize method instead of a instance variable.
  def collection_select (attribute, label, collection, value_method, text_method, options={})
    @fields << {
      :type         => :collection_select,
      :name         => field_name(attribute),
      :value        => field_value(attribute),
      :label        => label,
      :collection   => collection,
      :value_method => value_method,
      :text_method  => text_method,
      :options      => options,
    }

    self
  end

  ################################################################################
  protected

  ################################################################################
  def field (type, attribute, label, options)
    @fields << {
      :type     => type, 
      :name     => field_name(attribute), 
      :value    => field_value(attribute),
      :label    => label, 
      :options  => options
    }

    self
  end

  ################################################################################
  def field_name (attribute)
    @for_object ? "#{@for_object.class.to_s.underscore}[#{attribute}]" : attribute
  end
  
  ################################################################################
  def field_value (attribute)
    @for_object ? @for_object.send(attribute) : nil
  end

end
################################################################################
