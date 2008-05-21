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
    attr_accessor :configuration
    attr_accessor :proxy

    ################################################################################
    # Create a new TableMaker::Table object for the given model class, options include:
    #
    # * +:object+       If this table is for an association, give the owner object
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
      @configuration = {
        :object      => nil,
        :association => nil,
        :params      => {},
        :controller  => nil,
        :columns     => {},
        :controls    => nil,
        :per_page    => 25,
        :sort        => nil,
        :id          => nil,
        :filter      => nil,

      }.update(options)

      @model = model
      @uid = self.class.unique_name(@model, @configuration[:id])
      @configuration[:uid] = @uid
      controller_table_config = "#{@uid}_config"
      
      if c = @configuration[:controller] and c.class.respond_to?(controller_table_config)
        controller_config = c.class.send(controller_table_config)

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

      if @configuration[:association]
        association_proxy = @configuration[:object].send(@configuration[:association])
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

      @proxy = Proxy.for_model(@model, @configuration)
      @configuration[:state].proxy = @proxy

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
      html_configuration = {
        :id      => nil,
        :cycle   => ActionView::Helpers::TextHelper::Cycle.new('even', 'odd'),
        :if_none => nil,
        :caption => nil,
        :form    => true,

      }.update(options)

      if @configuration[:params] and @configuration[:params]["show_#{@uid}_form"]
        return @proxy.generate_html_table_form
      end

      @proxy.format = :html
      html = %Q(<div id="#{@uid}">)

      id_attr = html_configuration[:id] ? %Q(id="#{html_configuration[:id]}") : ''
      html << %Q(<table #{id_attr} class="table_maker" colspacing="0">)
      html << %Q(<caption>#{html_configuration[:caption]}</caption>) if html_configuration[:caption]

      # Add the header row
      html << %Q(<thead><tr>)

      if @configuration[:url]
        @proxy.columns.each_with_index do |column, i|
          heading = @proxy.headings[i]
          direction = :asc
          css_class = 'sortable'

          if @sort_info.column == column
            css_class = @sort_info.direction == :asc ? 'sorted_down' : 'sorted_up'
            direction = @sort_info.direction == :asc ? :desc : :asc
          end

          if @proxy.sortable_column?(column)
            url = @configuration[:state].url_to_sort(@configuration[:url], column, direction)
            html << %Q(<th class="#{css_class}">)
            html << @proxy.link_to_remote(heading, {:url => url}, {:class => css_class})
            html << %Q(</th>)
          else
            html << %Q(<th>#{heading}</th>)
          end
        end
      else
        html << @proxy.headings.map {|h| %Q(<th>#{h}</th>)}.join
      end

      html << %Q(</tr></thead>)

      @rows.each do |row|
        html << %Q(<tr class="#{html_configuration[:cycle]}">)

        @proxy.columns.each do |column|
          html << %Q(<td class="#{column}_column">)
          html << @proxy.display_value_for(row, column, :escape_html => true)
          html << %Q(</td>)
        end

        html << %Q(</tr>)
      end

      if @rows.empty? and html_configuration[:if_none]
        html << %Q(<tr><td colspan="#{@proxy.columns.length}" class="blank_table">)
        html << html_configuration[:if_none]
        html << %Q(</td></tr>)
      end

      if @configuration[:url]
        html << %Q(<tr class="footer_row">)
        html << %Q(<td colspan="#{@proxy.columns.length}">)

        if @paginator and @paginator.page_count > 1
          html << %Q(<span>) << @proxy.pagination_links_for(@paginator) << %Q(</span>)
        elsif @configuration[:per_page].kind_of?(Integer) and @rows.length > @configuration[:per_page]
          html << %Q(<span>) 
          html << @proxy.link_to_remote('Paginate', :url => @configuration[:state].url_to_toggle_pagination(@configuration[:url]))
          html << %Q(</span>)
        end

        if html_configuration[:form]
          html << %Q(<span class="table_form_link">) 
          html << @proxy.link_to_remote('Options', :url => @configuration[:url].merge("show_#{@uid}_form" => true))
          html << %Q(</span>)
        end

        html << %Q(</td>)
        html << %Q(</tr>)
      end

      html << %Q(</table>)
      html << %Q(<div id="#{@uid}_form" class="table_options_form" style="display: none;"><div id="#{@uid}_form_div"></div></div>) if @configuration[:url]
      html << %Q(</div>)
      html
    end

    ################################################################################
    # Generate RTF
    def to_rtf (options={})
      configuration = {
        :with_header => true,
        :legend => nil,

      }.update(options)

      require 'table_maker/rtf_helper'
      @columns = @proxy.columns

      @proxy.format = :rtf
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
          table[row_index][index].apply(bold) << @proxy.headings[index].to_s
        end

        row_index += 1
      end

      @proxy.rtf_link_reset do
        @rows.each do |row|
          @columns.each_with_index do |col, index|
            @proxy.current_rtf_node = table[row_index][index]
            table[row_index][index] << @proxy.display_value_for(row, col).to_s
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
      @proxy.format = :csv
      result = ''

      @proxy.csv_link_reset do
        CSV::Writer.generate(result) do |writer|
          writer << @proxy.headings if configuration[:with_header]
          @rows.each {|r| writer << @proxy.columns.map {|c| @proxy.display_value_for(r, c)}}
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

        @paginator = ActionController::Pagination::Paginator.new(self, count, @configuration[:per_page], page)
        @find_options[:limit]  = @paginator.items_per_page
        @find_options[:offset] = @paginator.current.offset
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
      if @proxy.sort_options.has_key?(@sort_info.column)
        if @proxy.sort_options[@sort_info.column].has_key?(:joins)
          @find_options[:joins] ||= ""
          @find_options[:joins] << @proxy.sort_options[@sort_info.column][:joins]
        end

        if @proxy.sort_options[@sort_info.column].has_key?(:include)
          @find_options[:include] ||= []

          if @proxy.sort_options[@sort_info.column][:include].is_a?(Array)
            @find_options[:include] += @proxy.sort_options[@sort_info.column][:include]
          else
            @find_options[:include] << @proxy.sort_options[@sort_info.column][:include]
          end
        end
      end

      @rows = @configuration[:find].call(:all, @find_options)

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
      unless @proxy.sort_options[@sort_info.column].blank?
        return @proxy.sort_options[@sort_info.column][@sort_info.direction]
      end

      # handle any columns on this table
      if @proxy.sortable_column?(@sort_info.column)
        return "#{@sort_info.column} #{@sort_info.direction}"
      end

      nil
    end

  end
end
################################################################################
