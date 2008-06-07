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
  module ActionControllerMethods
    ################################################################################
    NON_COLUMN_ACTIONS = %Q(id action controller)

    ################################################################################
    def table_for (model, options={})
      configuration = {
        :url     => {},
        :partial => nil,
        :setup   => nil,
        :id      => nil,
        :editor  => false,

      }.update(options)

      uid = TableMaker::Table.unique_name(model, configuration[:id])
      configuration[:uid] = uid
      configuration[:model] = model

      class << self
        self
      end.instance_eval <<-EOT
        @#{uid}_config = configuration
      EOT

      # Add our configuration grabber
      if !self.respond_to?(:table_maker_config)
        extend TableMaker::ActionControllerMethods::ClassMethods
      end

      # Add a method to redraw the entire table via Ajax
      define_method("redraw_#{uid}") do
        uid = @action_name.sub(/^redraw_/, '')
        config = self.class.table_maker_config(uid)
        self.send(config[:setup]) if config[:setup]

        if params["show_#{uid}_form"]
          render(:update) do |page| 
            page.replace_html(uid + '_form_div', :partial => config[:partial])
            page << visual_effect(:toggle_slide, uid + '_form')
            page << visual_effect(:scroll_to, uid + '_form')
          end
        else
          render(:update) {|p| p.replace(uid, :partial => config[:partial])}
        end
      end

      # Add a method to dispatch in_place_edit calls
      if configuration[:editor]
        define_method("update_from_#{uid}") do
          uid = @action_name.sub(/^update_from_/, '')
          config = self.class.table_maker_config(uid)
          self.send(config[:setup]) if config[:setup]

          options = TableMaker::Table.default_options
          options.update(:controller => self, :id => config[:id])
          options[:state] = TableMaker::State.new(options)

          record = config[:model].find(params[:id])
          columns = params.keys.reject {|k| NON_COLUMN_ACTIONS.include?(k.to_s)}

          view_helper = TableMaker::Helper.for_model(config[:model], options)
          columns.each {|c| view_helper.value_from_editor(record, c.to_sym, params[c])}
          render(:text => view_helper.display_value_for(record, columns.first.to_sym, :escape_html => true))
        end
      end
    end

    ################################################################################
    module ClassMethods
      ################################################################################
      def table_maker_config (uid)
        class << self; self end.instance_eval("@#{uid}_config")
      end

    end
  end
end
################################################################################
