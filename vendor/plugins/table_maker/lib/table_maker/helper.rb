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
module TableMaker
  ################################################################################
  # Helper class for working with ActiveRecord models
  class Helper < ActionView::Base
    ################################################################################
    CONTROLS_COLUMN_NAME = 'controls_column'

    ################################################################################
    class << self
      def default_column_options
        instance_eval do
          @column_options ||= {
            :order    => [],
            :include  => [],
            :exclude  => [],
            :fake     => [],
            :hide     => [],
            :link     => [],
          }
        end
      end

      def default_editor_columns
        instance_eval {@editor_columns ||= {:include => [], :exclude => []}}
      end

      def default_sort_options () instance_eval {@sort_options ||= {}} end
      def default_delegates    () instance_eval {@delegates ||= []}    end
    end

    ################################################################################
    # Try to load a Helper sub-class to handel this model
    def self.for_model (model, options={})
      file = model.name.to_s.underscore + '_table_helper.rb'
      path = File.join(RAILS_ROOT, 'app', 'table_helpers', file)

      if File.exists?(path)
        require_dependency(path)
        Object.const_get("#{model.name}TableHelper").new(model, options)
      else
        self.new(model, options)
      end
    end

    ################################################################################
    # Add code to the child class
    def self.inherited (klass)
      klass.class_eval("def initialize (model, options={}) super; end")
      klass.send(:include, ApplicationHelper)
      ActionController::Routing::Routes.named_routes.install(klass)
    end

    ################################################################################
    def self.columns (options={})
      if options[:only]
        options[:include] = options[:only]
        options[:order]   = options[:only]
        options.delete(:only)
      end

      column_options = default_column_options
      options.assert_valid_keys(column_options.keys)
      options.each {|k,v| v.is_a?(Array) ? column_options[k].concat(v) : column_options[k] = v}
    end

    ################################################################################
    def self.editor (options={})
      options.assert_valid_keys(:include, :exclude)
      editor_columns = default_editor_columns
      options.each {|k,v| editor_columns[k].concat(v)}
    end

    ################################################################################
    def self.sort (column, options)
      options.assert_valid_keys(:asc, :desc, :include, :joins)
      sort_options = default_sort_options
      sort_options[column] = options
    end

    ################################################################################
    def self.delegate (model, association=nil)
      association ||= model.name.underscore
      default_delegates << [model, association]
    end

    ################################################################################
    def self.default_url_options
      message = "Without a controller, you cannot use any of the URL generation"
      message << " methods such as url_for or link_to without first adding a class"
      message << " method to your table_helper class called default_url_options."
      message << " Please see ActionController::UrlWriter for more info."
      
      raise message
    end

    ################################################################################
    attr_reader :headings
    attr_reader :columns
    attr_reader :editor_columns
    attr_reader :sort_options
    attr_reader :format

    ################################################################################
    def initialize (model, options={})
      @model      = model
      @options    = options
      @controller = @options[:controller]
      @format     = :html
      @link_to    = nil

      if @controller.nil? 
        class << self; include ActionController::UrlWriter; end
      else
        # grab instance variables from our controller
        @controller.instance_variables.each do |iv|
          instance_variable_set(iv, @controller.instance_variable_get(iv))
        end
      end

      @options[:state] ||= TableMaker::State.new(@options)
      lookup_model_attributes
      prepare_column_state
      prepare_editor_columns
      prepare_sort_options
      prepare_delegates
    end
    
    ################################################################################
    # Set the output format
    def format= (format)
      @format = format
      @delegates.each {|d| d.first.format = format}
    end

    ################################################################################
    def link_to= (method)
      @link_to = method
    end

    ################################################################################
    def reset_link_to (other_method, &block)
      # Force the link method to point to this object unless it is already
      # a Method object, in which case we let it go where the caller wants
      other_method = self.method(other_method) unless Method === other_method

      old_link_to = @link_to
      @link_to = other_method
      @delegates.each {|d| d.first.link_to = @link_to}
      yield if block_given?
    ensure
      @link_to = old_link_to
      @delegates.each {|d| d.first.link_to = @link_to}
    end

    ################################################################################
    def heading_for (name)
      heading =
        if self.respond_to?("heading_for_#{name}")
          self.send("heading_for_#{name}")
        elsif name.to_s == 'id'
          name.to_s.upcase
        else
          name.to_s.titlecase
        end

      ERB::Util::html_escape(heading)
    end

    ################################################################################
    define_method("heading_for_#{CONTROLS_COLUMN_NAME}") do 
      " "
    end

    ################################################################################
    def display_value_for (object, method, options={})
      configuration = {
        :escape_html => false,

      }.update(options)

      helper_method = display_method(method, @format)

      if self.respond_to?(helper_method)
        value = self.send(helper_method, object)
      elsif delegate = @delegates.find {|d| d.first.respond_to?(helper_method)}
        value = delegate.first.send(helper_method, object.send(delegate.last))
      else
        case @attributes[method]
        when ActiveRecord::ConnectionAdapters::Column
          value = object.send(method)
        when ActiveRecord::Reflection::AssociationReflection
          value = value_for_association(object, method)
        end

        value = ERB::Util::html_escape(value) if configuration[:escape_html]
      end

      if @column_options[:link] == :all or Array(@column_options[:link]).include?(method)
        if self.respond_to?(:url)
          url_for_link = self.url(object)
        else
          url_for_link = {:controller => object.class.to_s.underscore.pluralize, :action => 'show', :id => object}
        end

        value = link_to(value, url_for_link)
      end

      value
    end

    ################################################################################
    def display_method (column, format)
      column
    end

    ################################################################################
    define_method(CONTROLS_COLUMN_NAME) do |object|
      "&nbsp;"
    end

    ################################################################################
    # Save new table cell values coming from the in-place editor
    def value_from_editor (object, column, value)
      return unless @editor_columns.include?(column)

      if self.respond_to?("#{column}=")
        self.send("#{column}=", object, value)
      else
        object.send("#{column}=", value)
        object.save!
      end
    end

    ################################################################################
    def formatted_for (&block)
      catch (:output) do
        yield(TableMaker::FormatHelper.new(@format))
      end
    end

    ################################################################################
    def value_for_association (object, method)
      case @attributes[method].macro
      when :belongs_to, :has_one
        value_from_association_record(method, record = object.send(method))

      when :has_many
        object.send(method).count
      end
    end

    ################################################################################
    def value_from_association_record (method, record)
      return '' if record.nil?

      if record.respond_to?(:name)
        record.name
      elsif record.respond_to?(:title)
        record.title
      else
        record.to_s
      end
    end

    ################################################################################
    def sortable_column? (column)
      return true if sort_options.has_key?(column)
      @model.columns.map(&:name).include?(column.to_s)
    end

    ################################################################################
    def pagination_links_for (paginator)
      url = @options[:url]
      html = 'Page: '

      html << pagination_links_each(paginator, {}) do |number|
        link_to_remote(number.to_s, :url => url.merge(:page => number))
      end

      if paginator.current.next
        html << (' ' + link_to_remote("Next", :url => url.merge(:page => paginator.current.next)))
      end

      html << (' ' + link_to_remote("All", :url => @options[:state].url_to_toggle_pagination(url)))
      html
    end

    ################################################################################
    def generate_html_table_form
      state = @options[:state]

      form_id = "#{@options[:uid]}_form"
      form = EasyForms::Description.new(state)

      form.subform(state.html_form)
      form.button('Update')
      form.button('Cancel', :do => lambda {|p| p << visual_effect(:toggle_slide, form_id)})

      generate_form_from(form, :legend => 'Table Options', :xhr => true, :url => @options[:url])
    end

    ################################################################################
    # yield the columns in sorted order
    def attributes_in_order
      if @column_options[:order].empty? and @allowed_column_list.include?(:id)
        @column_options[:order] << :id
      end

      sorted = @allowed_column_list.sort {|a,b| a.to_s <=> b.to_s}.uniq

      @column_options[:order].reverse.each do |column|
        sorted.unshift(column) if sorted.delete(column)
      end

      # two special columns that always get moved to the end
      [:created_on, :updated_on].each do |column|
        unless @column_options[:order].include?(column)
          sorted << column if sorted.delete(column)
        end
      end

      case @options[:controls]
      when :before
        sorted.unshift(CONTROLS_COLUMN_NAME)
      when :after
        sorted.push(CONTROLS_COLUMN_NAME)
      end

      sorted.each {|k| yield(k)}
    end

    ################################################################################
    def link_to (*args)
      @link_to.nil? ? super : @link_to.call(*args)
    end

    ################################################################################
    def method_missing (name, *args, &block)
      if @controller and @controller.respond_to?(name)
        @controller.send(name, *args, &block)
      else
        super
      end
    end

    ################################################################################
    private

    ################################################################################
    def lookup_model_attributes
      # Load all attributes
      @attributes = Hash[*@model.columns.map{|c| [c.name.to_sym, c]}.flatten]

      # Load all associations
      @model.reflect_on_all_associations.each do |assoc|
        @attributes.delete(assoc.primary_key_name.to_sym) if assoc.macro == :belongs_to
        @attributes[assoc.name] = assoc
      end
    end

    ################################################################################
    # strip down the columns to the requested set
    def prepare_column_state
      # Setup the local column options hash
      @column_options = @options[:columns]

      # Fix column options given to the table class
      if @column_options.has_key?(:only)
        @column_options[:include] = @column_options[:only]
        @column_options[:order]   = @column_options[:only]
      end

      # Make a list of all possible columns for display
      @allowed_column_list = @attributes.keys

      self.class.default_column_options.each do |k,v|
        @column_options[k] = @column_options[k].dup if @column_options[k].is_a?(Array)
        @column_options[k] = Array(@column_options[k])
        v.is_a?(Array) ? @column_options[k].concat(v) : @column_options[k] = v
      end

      # Remove excluded columns
      @column_options[:exclude].each {|c| @allowed_column_list.delete(c)}

      # Restrict to columns in :include
      unless @column_options[:include].empty?
        @allowed_column_list.delete_if {|k| !@column_options[:include].include?(k)}
      end

      # Add fake columns
      @allowed_column_list += @column_options[:fake]
      
      # Setup the state object to contain the list of allowed columns
      if @options[:state].columns.empty?
        @options[:state].columns = @allowed_column_list - @column_options[:hide]
      end

      @headings = []
      @columns  = []

      attributes_in_order do |name|
        if name != CONTROLS_COLUMN_NAME
          next unless @options[:state].columns.include?(name)
        end

        @headings << heading_for(name)
        @columns  << name.to_sym
      end
    end

    ################################################################################
    def prepare_editor_columns
      default_columns = self.class.default_editor_columns
      @editor_columns = @allowed_column_list.dup if default_columns[:include].empty?
      @editor_columns ||= default_columns[:include].dup
      @editor_columns.delete_if {|c| default_columns[:exclude].include?(c)}
    end

    ################################################################################
    def prepare_sort_options 
      @sort_options = self.class.default_sort_options

      # Add desc sort option for sorts that are missing them
      @sort_options.each do |key, value|
        value[:desc] = value[:asc].gsub(/(?:\bASC\b|$)/i, " DESC") if value[:desc].nil?
      end
    end

    ################################################################################
    def prepare_delegates
      @delegates = self.class.default_delegates.uniq.map do |c| 
        [self.class.for_model(c.first, @options), c.last]
      end
    end

    ################################################################################
    # This is necessary to display ID's when the user's helper class doesn't
    # have a display method for ID's
    def id (object)
      object.id
    end

  end
end
################################################################################
