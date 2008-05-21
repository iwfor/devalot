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
  # These are methods that are added to ActionController::Base
  module ActionControllerBaseMethods
    ################################################################################
    # Add instance methods to the calling controller that help respond to tag
    # editing requests from the remote user.  Also adds a view helper that you
    # can use to generate a tag editing form similar to the inplace editor.
    #
    #  class ArticlesController < ApplicationController
    #    tagging_helper_for Article
    #  end
    def tagging_helper_for (model)
      suffix = model.to_s.underscore

      # controller method to handle tag additions
      define_method("add_tags_to_#{suffix}".to_sym) do
        @record = model.find(params[:id])
        @record.tags.add(params[:tags])
        send("tag_cloud_for_#{suffix}")
      end

      # controller method to handle tag removals
      define_method("remove_tags_from_#{suffix}".to_sym) do
        @record = model.find(params[:id])
        @record.tags.remove(params[:tags])
        send("tag_cloud_for_#{suffix}")
      end

      # controller method to redraw the tag cloud
      define_method("tag_cloud_for_#{suffix}") do 
        @record ||= model.find(params[:id])
        render(:inline => %Q(<%= tag_cloud_for(@record) %>))
      end

      helper(TaggingPlugin::ActionViewHelperMethods)
    end

    ################################################################################
    # Use this method to add instance methods to a controller you are using
    # for viewing a site wide tag cloud and lists of items that are tagged
    # with a specific tag. See TagsControllerInstanceMethods.
    #
    #  class TagsController < ApplicationController
    #    tagging_controller_helpers
    #
    #    def show
    #      @pages, @taggings = tagging_paginator
    #    end
    #  end
    def tagging_controller_helpers
      include TaggingPlugin::ActionControllerBaseMethods::TagsControllerInstanceMethods
      helper(TaggingPlugin::ActionViewHelperMethods)
    end

    ################################################################################
    # Methods that get added when you use the class method
    # tagging_controller_helpers.
    module TagsControllerInstanceMethods
      ################################################################################
      # Create a paginator for taggings that belong to the tag that is in
      # params[:id].  Options include:
      #
      # * +:per_page+  The number of items to show per page (default is 10)
      # * +:parameter+ The params parameter that tells us what page we are on (default is page)
      # * +:order+     The order to pull taggings from the database (default is created_on DESC)
      #
      # Sets @tag, @taggins, and @pages, returns [@pages, @taggings]
      #
      #  @pages, @taggings = tagging_paginator
      def tagging_paginator (options={})
        configuration = {
          :per_page  => 10,
          :parameter => 'page',
          :order     => 'created_on DESC',

        }.update(options)

        page = params[configuration[:parameter]] || 1
        @tag = Tag.find(params[:id])

        @pages = ActionController::Pagination::Paginator.new(self, @tag.reference_count, 
                                                             configuration[:per_page], page)
        @taggings = Tagging.find(:all, {
          :conditions => {:tag_id => @tag.id}, 
          :order      => configuration[:order],
          :limit      => configuration[:per_page],
          :offset     => @pages.current.offset,
        })

        [@pages, @taggings]
      end
    end

  end
end
################################################################################
