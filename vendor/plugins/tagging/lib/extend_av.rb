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
module TaggingPlugin
  ################################################################################
  # These methods are added as helper methods to the view when you use the
  # controller method tagging_helper_for.
  module ActionViewHelperMethods
    ################################################################################
    # Generate HTML for a tag editor that uses Ajax to submit tags to be added
    # and removed.  Options include:
    #
    # * +:add_button+       HTML or link title for the add tags trigger (default is '+')
    # * +:remove_button+    HTML or link title for the remove tags trigger (default is '-')
    # * +:visual_effect+    The visual effect to use for showing/hiding the
    #                       form, this must be one of the toggle visual effects
    #                       (default is :toggle_slide)
    # * +:style+            Initial CSS style on the created div (default is 'display: none;')
    # * +:text_field_class+ The CSS class to set on text fields (default is 'tag_editor')
    #
    # The form updates the HTML added to the page by the tag_cloud_for method,
    # so you'll need to call that as well.
    def tag_editor_for (record, options={})
      configuration = {
        :add_button => '+',
        :remove_button => '-',
        :visual_effect => :toggle_slide,
        :style => 'display: none;',
        :text_field_class => 'tag_editor',

      }.update(options)

      suffix = record.class.to_s.underscore

      html_ids = {
        'add'    => "tag_add_editor_for_#{suffix}_#{record.id}",
        'remove' => "tag_remove_editor_for_#{suffix}_#{record.id}",
      }

      url_actions = {
        'add'    => "add_tags_to_#{suffix}",
        'remove' => "remove_tags_from_#{suffix}",
      }

      actions = %W(add remove)
      html = ""

      actions.each do |action|
        html << link_to_function(configuration["#{action}_button".to_sym], nil, :class => "tag_#{action}_link") do |page|
          # clear the input field just in case it's used more than once
          page << "$('tags_#{action}_field_for_#{suffix}_#{record.id}').value = '';"

          if configuration[:visual_effect]
            page << visual_effect(configuration[:visual_effect], html_ids[action])
          else
            page[html_ids[action]].show
          end
        end

        html << " "
      end

      actions.each do |action|
        form_complete = 
          if configuration[:visual_effect]
            visual_effect(configuration[:visual_effect], html_ids[action])
          else
            nil
          end

        form_url = {:action => url_actions[action], :id => record.id}

        html << %Q(<div id="#{html_ids[action]}" style="#{configuration[:style]}"><div>)
        html << form_remote_tag(:url => form_url, :complete => form_complete, :update => "tag_cloud_for_#{suffix}_#{record.id}")
        html << text_field_tag('tags', nil, :id => "tags_#{action}_field_for_#{suffix}_#{record.id}", :class => configuration[:text_field_class])

        html << button_to_function("Cancel") do |page| 
          if configuration[:visual_effect]
            page << visual_effect(configuration[:visual_effect], html_ids[action])
          else
            page[html_ids[action]].hide
          end
        end

        html << submit_tag("#{action.capitalize} Tags")
        html << %Q(</form></div></div>)
      end

      html
    end

    ################################################################################
    # Generate a HTML tag cloud for the given record.  The default
    # configuration will generate links to the tags controller where each link
    # has a class of cloud_1 through cloud_9 depending on how often that tag
    # is used in the database.
    #
    # You can override this behavior, but be aware that you'll have to also
    # redefine the tag_cloud_for_XXX method on your controller since the
    # default calls this method with no options.
    #
    # Options include:
    #
    # * +:element+     The HTML element to put the tag cloud inside (default is p)
    # * +:categories+  An array of categories (default is ('cloud_1' .. 'cloud_9'))
    # * +:controller+  When generating links, use this controller (default is 'tags')
    # * +:action+      When generating links, use this action (default is 'show')
    #
    # If you would like to generate your own tag cloud, you can give a block
    # to this method.  In that case, it will be yielded to for each tag, and
    # given the tag and the correct category.
    #
    # Rememeber, if you give a block, you'll probably want to write a partial
    # that calls this method, and redefine the tag_cloud_for_XXX method in
    # your controller where XXX is the model name in underscore format.
    #
    # Default Usage:
    #
    #  <%= tag_cloud_for(@article) %>
    #
    # Give your own categories:
    #
    #  <%= tag_cloud_for(@article, :categories => %W(small medium large)) %>
    #
    # Using your own block:
    #
    #  # Place this in views/articles/_tag_cloud.rhtml
    #  <%= tag_cloud_for(@article, :categories => %W(one two three)) do |tag, cat| %>
    #    <%= link_to(h(tag.name), {:action => 'foo'}, {:class => cat}) %>
    #  <% end %>
    #
    #  # Place this in your controller (after the tagging_helper_for Article)
    #  def tag_cloud_for_article
    #    @article ||= Article.find(params[:id])
    #    render(:partial => 'tag_cloud')
    #  end 
    #
    #  # Place this in views/articles/show.rhtml
    #  <%= render(:partial => 'tag_cloud') %>
    #
    # Also note that you can define a method in an active helper module called
    # url_for_tag_in_tag_cloud that tags a tag object, and should return a URL
    # that will be used for linking to that tag in the tag cloud.
    def tag_cloud_for (record, options={}, &block)
      configuration = {
        :element => 'div',
        :categories => ('cloud_1' .. 'cloud_9').to_a,
        :controller => 'tags',
        :action     => 'show',
        :when_none  => "This #{record.class.to_s.underscore} hasn't been tagged yet."

      }.update(options)

      element_id = "tag_cloud"
      element_id << "_for_#{record.class.to_s.underscore}_#{record.id}" if record.kind_of?(ActiveRecord::Base)

      wrapper_start = %Q(<#{configuration[:element]} id="#{element_id}">)
      wrapper_end   = %Q(</#{configuration[:element]}>)
      result        = ""

      if record.tags.empty?
        result = wrapper_start + configuration[:when_none] + wrapper_end
        concat(result, block) if block_given?
        return result
      end

      cloud = TaggingPlugin::Cloud.new(record.tags, configuration[:categories])

      if block_given?
        concat(wrapper_start, block)
        cloud.tags_with_category(&block)
        concat(wrapper_end, block)
      else
        result << wrapper_start
        cloud.tags_with_category do |tag, cat|
          html = {:class => cat}
          url = nil

          if self.respond_to?(:url_for_tag_in_tag_cloud)
            url = self.url_for_tag_in_tag_cloud(tag)
          else
            url = {:controller => configuration[:controller], :action => configuration[:action], :id => tag}
          end

          result << link_to(ERB::Util.html_escape(tag.name), url, html) + " "
        end
        result << wrapper_end
      end

      result
    end

  end
end
################################################################################
