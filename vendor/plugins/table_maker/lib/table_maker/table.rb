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
  # The TableMaker::Table class is used to generate a table in multiple output
  # formats.
  class Table
    ################################################################################
    # Helper method to generate a unique name for a table
    def self.unique_name (model, id)
      name = model.to_s.underscore
      name << "_#{id}" if id
      name << "_table"
      name
    end

    ################################################################################
    # Get the default options for a new table object
    def self.default_options
      {
        :from        => nil,
        :association => nil,
        :params      => {},
        :controller  => nil,
        :columns     => {},
        :controls    => nil,
        :per_page    => 25,
        :sort        => nil,
        :id          => nil,
        :filter      => nil,
      }
    end

    ################################################################################
    attr_accessor :configuration
    attr_accessor :view_helper

    ################################################################################
    # Create a new TableMaker::Table object for the given model class, options include:
    #
    # * +:from+         If this table is for an association, give the owner object
    # * +:association+  The association to build a table for (optional)
    # * +:params+       Pass in the current params for sorting
    # * +:controller+   The parent controller
    # * +:columns+      Override column settings
    # * +:controls+     Include a column to hold row controls
    # * +:per_page+     If paginating, limit table to this many rows
    # * +:sort+         Default sort column and direction like: [:created_on, :desc]
    # * +:id+           Suffix for generating a UID for this table
    #
    # You should use the table_for ActionView template helper method to make
    # this call easier.
    #
    def initialize (model, options={}, options_for_find={})
      @model = model
      @configuration = self.class.default_options.update(options)
      @uid = self.class.unique_name(@model, @configuration[:id])
      @configuration[:uid] = @uid
      
      if c = @configuration[:controller] and c.class.respond_to?(:table_maker_config)
        if controller_config = c.class.table_maker_config(@uid)

          # figure out what URL to use for generated links
          @configuration[:url] = 
            case controller_config[:url]
            when Symbol
              c.send(controller_config[:url])
            when Proc
              controller_config[:url].call(c)
            when Hash
              controller_config[:url]
            end

          @configuration[:url].update(:action => "redraw_#{@uid}")
        end
      end

      # The default asociation name is guessed from the model name
      if @configuration[:from] and @configuration[:association].nil?
        @configuration[:association] = @model.name.underscore.pluralize
      end

      if @configuration[:association] && @configuration[:from]
        association_proxy = @configuration[:from].send(@configuration[:association])
        @configuration[:find]  = lambda {|i,j| association_proxy.find(i,j)}
        @configuration[:count] = lambda {|a| association_proxy.count(a)}
      else
        @configuration[:find]  = @model.method(:find)
        @configuration[:count] = @model.method(:count)
      end

      @configuration[:state] = TableMaker::State.new(@configuration)

      if c and c.request.xhr? and !@configuration[:params][:state].blank?
        @configuration[:state].attributes = @configuration[:params][:state]
      end

      @view_helper = Helper.for_model(@model, @configuration)
      @configuration[:state].view_helper = @view_helper

      @find_options = options_for_find
      fetch_rows

      @configuration[:state].save(@configuration)
    end
    
    ################################################################################
    # Get access to the state object
    def state
      @configuration[:state]
    end

    ################################################################################
    # Generate HTML with the default options
    def to_s
      to_html
    end

    ################################################################################
    # Generate HTML
    def to_html (options={})
      HTMLHelper.new(@view_helper, options, @configuration).generate
    end

    ################################################################################
    # Generate RTF
    def to_rtf (options={})
      configuration = {
        :with_header => true,
        :legend => nil,

      }.update(options)

      require 'table_maker/rtf_helper'
      @columns = @view_helper.columns

      @view_helper.format = :rtf
      rtf = RTF::Document.new(RTF::Font.new(RTF::Font::ROMAN, 'Arial'))

      if configuration[:legend]
        header_style = RTF::CharacterStyle.new
        header_style.bold = true
        header_style.font_size = 28

        rtf.document.paragraph(header_style) do |para|
          para << configuration[:legend]
        end
      end

      row_index  = 0
      total_rows = @rows.length
      total_rows += 1 if configuration[:with_header]

      table = rtf.table(total_rows, @columns.length, *Array.new(@columns.length, 9000/@columns.length))
      table.border_width = 5

      if configuration[:with_header]
        bold = RTF::CharacterStyle.new
        bold.bold = true

        @columns.each_with_index do |col, index| 
          table[row_index][index].apply(bold) << @view_helper.headings[index].to_s
        end

        row_index += 1
      end

      @view_helper.reset_link_to(:rtf_link_to) do
        @rows.each do |row|
          @columns.each_with_index do |col, index|
            @view_helper.current_rtf_node = table[row_index][index]
            table[row_index][index] << @view_helper.display_value_for(row, col).to_s
          end

          row_index += 1
        end
      end

      rtf.to_rtf
    end

    ################################################################################
    # Generate CSV
    def to_csv (options={})
      configuration = {
        :with_header => true,

      }.update(options)

      require 'table_maker/csv_helper'
      @view_helper.format = :csv
      result = ''

      @view_helper.reset_link_to(:csv_link_to) do
        CSV::Writer.generate(result) do |writer|
          writer << @view_helper.headings if configuration[:with_header]
          @rows.each {|r| writer << @view_helper.columns.map {|c| @view_helper.display_value_for(r, c)}}
        end
      end

      result
    end

    ################################################################################
    private

    ################################################################################
    def fetch_rows
      order = calculate_order
      @find_options[:order] = order unless order.nil?

      if @configuration[:url] and @configuration[:per_page] and @configuration[:state].paginate
        count = @configuration[:count].call(@find_options.merge(:order => nil))
        page  = @configuration[:params][:page] || 1
        @configuration[:paginator] = ActionController::Pagination::Paginator.new(self, count, @configuration[:per_page], page)
        @find_options[:limit]  = @configuration[:paginator].items_per_page
        @find_options[:offset] = @configuration[:paginator].current.offset
      end

      # the include option should be an array
      if @find_options[:include]
        if @find_options[:include].is_a?(Array)
          @find_options[:include] = @find_options[:include].dup
        else
          @find_options[:include] = Array(@find_options[:include])
        end
      end

      # add any includes needed by the current sort key
      if @view_helper.sort_options.has_key?(@sort_info.column)
        if @view_helper.sort_options[@sort_info.column].has_key?(:joins)
          @find_options[:joins] ||= ""
          @find_options[:joins] << @view_helper.sort_options[@sort_info.column][:joins]
        end

        if @view_helper.sort_options[@sort_info.column].has_key?(:include)
          @find_options[:include] ||= []

          if @view_helper.sort_options[@sort_info.column][:include].is_a?(Array)
            @find_options[:include] += @view_helper.sort_options[@sort_info.column][:include]
          else
            @find_options[:include] << @view_helper.sort_options[@sort_info.column][:include]
          end
        end
      end

      @rows = @configuration[:find].call(:all, @find_options)
      @configuration[:rows] = @rows

      if @configuration[:filter]
        @rows = @rows.select(&@configuration[:filter])
      end
    end

    ################################################################################
    def calculate_order
      # Pull from current request parameters
      @sort_info = @configuration[:state].sort_options

      # If not in params, try to use the default sort order
      if @sort_info.column.nil? and !@configuration[:sort].nil?
        sort_opt = @configuration[:sort]
        sort_opt = [sort_opt, :asc] unless sort_opt.is_a?(Array)
        @sort_info = OpenStruct.new(:column => sort_opt.first, :direction => sort_opt.last)
      end

      # return nil if there aren't any sort options in place
      return nil if @sort_info.column.nil?

      # make sure sort direction makes sense
      @sort_info.direction = :asc unless [:asc, :desc].include?(@sort_info.direction)

      # easy case, the sorting info was given in the table helper class
      unless @view_helper.sort_options[@sort_info.column].blank?
        return @view_helper.sort_options[@sort_info.column][@sort_info.direction]
      end

      # handle any columns on this table
      if @view_helper.sortable_column?(@sort_info.column)
        return "#{@model.table_name}.#{@sort_info.column} #{@sort_info.direction}"
      end

      nil
    end

  end
end
################################################################################
