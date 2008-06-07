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
  # Helper class to hold the state of the table for the current user
  class State
    ################################################################################
    attr_accessor :view_helper

    ################################################################################
    def initialize (options={})
      configuration = {
        :controller   => nil,
        :per_page     => true,
        :params       => {},
        :state        => {},

      }.update(options)

      @state = {
        :columns  => [],
        :paginate => true,
        :sort_col => nil,
        :sort_dir => nil,
      }

      self.paginate = configuration[:per_page].kind_of?(Integer)
      self.setup_from_db(configuration[:state])
      self.setup_from_session(configuration)
      self.attributes = configuration[:params] if configuration[:params]
    end

    ################################################################################
    def setup_from_db (options={})
      @db_configuration = {
        :object => nil,
        :method => nil,
        :mode   => :rw,

      }.update(options)

      if @db_configuration[:object]
        self.state = @db_configuration[:object].send(@db_configuration[:method])
      end
    end

    ################################################################################
    def setup_from_session (options={})
      if options[:controller]
        key = session_key(options[:controller], options[:uid])
        s = options[:controller].session[key]
        self.state = s unless s.blank?
      end
    end

    ################################################################################
    def attributes= (params)
      return if params.nil?
      new_columns = []

      params.keys.each do |key|
        if m = key.to_s.match(/^column_([a-z0-9_]+)$/)
          new_columns << m[1].to_sym
        end
      end

      @state[:columns]  = new_columns unless new_columns.empty?
      @state[:paginate] = params[:tmpg].to_s == 'true' unless params[:tmpg].blank?
      @state[:sort_col] = params[:tmsc] unless params[:tmsc].blank?
      @state[:sort_dir] = params[:tmsd] unless params[:tmsd].blank?
    end

    ################################################################################
    def url_to_sort (url, column, direction)
      url.merge(:tmsc => column, :tmsd => direction)
    end

    ################################################################################
    def url_to_toggle_pagination (url)
      url.merge(:tmpg => (!@state[:paginate]).to_s)
    end

    ################################################################################
    def sort_options
      @state[:sort_col] = @state[:sort_col].to_sym unless @state[:sort_col].blank?
      @state[:sort_dir] = @state[:sort_dir].to_sym unless @state[:sort_dir].blank?
      OpenStruct.new(:column => @state[:sort_col], :direction => @state[:sort_dir])
    end

    ################################################################################
    def columns
      @state[:columns] || []
    end

    ################################################################################
    def columns= (columns)
      @state[:columns] = columns
    end

    ################################################################################
    def state
      @state.to_yaml
    end

    ################################################################################
    def state= (state)
      @state = YAML::load(state) unless state.blank?
      raise "Bad TableMaker::State object from DB" unless @state.is_a?(Hash)
    end

    ################################################################################
    def paginate
      @state[:paginate]
    end

    ################################################################################
    def paginate= (flag)
      @state[:paginate] = flag
    end
    
    ################################################################################
    def html_form
      form = EasyForms::Description.new

      columns_form = EasyForms::Description.new(self) do |f|
        @view_helper.attributes_in_order do |column|
          next if column == Helper::CONTROLS_COLUMN_NAME
          f.check_box("column_#{column}".to_sym, @view_helper.heading_for(column))
        end
      end

      form.subform(columns_form, :legend => "Display Columns:")
      form
    end

    ################################################################################
    def save (configuration=nil)
      if configuration and configuration[:controller]
        # save the current state to the curren user's session
        key = session_key(configuration[:controller], configuration[:uid])
        configuration[:controller].session[key] = self.state
      end

      if @db_configuration[:object] and @db_configuration[:mode] == :rw
        @db_configuration[:object].send("#{@db_configuration[:method]}=", self.state)
        @db_configuration[:object].save
      end
    end

    ################################################################################
    def method_missing (method, *args)
      if m = method.to_s.match(/^column_(.+)$/)
        return columns.include?(m[1].to_sym)
      end

      nil
    end

    ################################################################################
    private

    ################################################################################
    def session_key (controller, uid)
      "#{controller.controller_name}_#{uid}_state"
    end

  end
end
################################################################################

