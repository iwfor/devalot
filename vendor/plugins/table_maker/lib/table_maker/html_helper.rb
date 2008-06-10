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
  class HTMLHelper
    ################################################################################
    def initialize (view_helper, options={}, table_opts={})
      @config = {
        :id      => nil,
        :cycle   => ActionView::Helpers::TextHelper::Cycle.new('even', 'odd'),
        :if_none => nil,
        :caption => nil,
        :form    => true,
        :editor  => false,

      }.update(options)

      # FIXME this is a strange way to pass options around
      @view_helper = view_helper
      @table_opts  = table_opts
      @paginator   = table_opts[:paginator]
      @rows        = table_opts[:rows]
      @uid         = table_opts[:uid]
      @sort_info   = table_opts[:state].sort_options
    end

    ################################################################################
    def generate
      if @table_opts[:params] and @table_opts[:params]["show_#{@uid}_form"]
        return @view_helper.generate_html_table_form
      end

      @view_helper.format = :html
      html = %Q(<div id="#{@uid}">)

      id_attr = @config[:id] ? %Q(id="#{@config[:id]}") : ''
      html << %Q(<table #{id_attr} class="table_maker" cellspacing="0">)
      html << %Q(<caption>#{@config[:caption]}</caption>) if @config[:caption]

      # Add the header row
      html << %Q(<thead><tr>)

      if @table_opts[:url]
        @view_helper.columns.each_with_index do |column, i|
          heading = @view_helper.headings[i]
          direction = :asc
          css_class = 'sortable'

          if @sort_info.column == column
            css_class = @sort_info.direction == :asc ? 'sorted_down' : 'sorted_up'
            direction = @sort_info.direction == :asc ? :desc : :asc
          end

          if @view_helper.sortable_column?(column)
            url = @table_opts[:state].url_to_sort(@table_opts[:url], column, direction)
            html << %Q(<th class="#{css_class}">)
            html << @view_helper.link_to_remote(heading, {:url => url}, {:class => css_class})
            html << %Q(</th>)
          else
            html << %Q(<th>#{heading}</th>)
          end
        end
      else
        html << @view_helper.headings.map {|h| %Q(<th>#{h}</th>)}.join
      end

      html << %Q(</tr></thead>)
      html << html_for_rows

      if @table_opts[:url]
        html << %Q(<tr class="footer_row">)
        html << %Q(<td colspan="#{@view_helper.columns.length}">)

        if @paginator and @paginator.page_count > 1
          html << %Q(<span>) << @view_helper.pagination_links_for(@paginator) << %Q(</span>)
        elsif @table_opts[:per_page].kind_of?(Integer) and @rows.length > @table_opts[:per_page]
          html << %Q(<span>) 
          html << @view_helper.link_to_remote('Paginate', :url => @table_opts[:state].url_to_toggle_pagination(@table_opts[:url]))
          html << %Q(</span>)
        end

        if @config[:form]
          html << %Q(<span class="table_form_link">) 
          html << @view_helper.link_to_remote('Options', :url => @table_opts[:url].merge("show_#{@uid}_form" => true))
          html << %Q(</span>)
        end

        html << %Q(</td>)
        html << %Q(</tr>)
      end

      html << %Q(</table>)
      html << %Q(<div id="#{@uid}_form" class="table_options_form" style="display: none;"><div id="#{@uid}_form_div"></div></div>) if @table_opts[:url]
      html << %Q(</div>)
      html
    end

    ################################################################################
    def html_for_rows
      html = ""

      @rows.each do |row|
        html << %Q(<tr class="#{@config[:cycle]}">)

        @view_helper.columns.each do |column|
          html << %Q(<td class="#{column}_column">)
          html << html_for_cell(row, column)
          html << %Q(</td>)
        end

        html << %Q(</tr>)
      end

      if @rows.empty? and @config[:if_none]
        html << %Q(<tr><td colspan="#{@view_helper.columns.length}" class="blank_table">)
        html << @config[:if_none]
        html << %Q(</td></tr>)
      end

      html
    end

    ################################################################################
    def html_for_cell (row, column)
      if @config[:editor] and @view_helper.editor_columns.include?(column)
        editor_html_for_cell(row, column)
      else
        @view_helper.display_value_for(row, column, :escape_html => true)
      end
    end

    ################################################################################
    def editor_html_for_cell (row, column)
      dom_id = %Q(#{row.dom_id}_#{column})

      value = @view_helper.display_value_for(row, column, :escape_html => true)
      value = "&nbsp;" if value.blank? # FIXME there has to be something better
      html = %Q(<div id="#{dom_id}">#{value}</div>)

      editor_url = @table_opts[:url].merge(:action => "update_from_#{@uid}", :id => row)
      editor_url = @view_helper.url_for(editor_url)

      js = %Q(new TableMaker.CellEditor('#{dom_id}', '#{column}', '#{editor_url}'))
      html << @view_helper.javascript_tag(js)
    end

  end
end
################################################################################
