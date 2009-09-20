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
    def table_for (model, options={})
      configuration = {
        :url     => {},
        :partial => nil,
        :setup   => nil,
        :id      => nil,

      }.update(options)

      uid = TableMaker::Table.unique_name(model, configuration[:id])
      configuration[:uid] = uid

      # Add instance variable to the metaclass
      class << self
        self
      end.instance_eval <<-EOT
        @#{uid}_config = configuration
      EOT

      # Add these methods to the metaclass
      class_eval <<-EOT
        def self.#{uid}_config
          class << self; instance_eval {@#{uid}_config}; end
        end

        def redraw_#{uid}
          config = self.class.#{uid}_config
          self.send(config[:setup]) if config[:setup]

          if params[:show_#{uid}_form]
            render(:update) do |page| 
              page.replace_html(config[:uid] + '_form_div', :partial => config[:partial])
              page << visual_effect(:toggle_slide, config[:uid] + '_form')
              page << visual_effect(:scroll_to, config[:uid] + '_form')
            end
          else
            render(:update) {|p| p.replace(config[:uid], :partial => config[:partial])}
          end
        end
      EOT
    end

  end
end
################################################################################
