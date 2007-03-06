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
module Commentable
  ################################################################################
  module ExtendActionController
    ################################################################################
    COMMENT_CONTROLLER_METHODS = [:create_comment, :edit_comment, :update_comment, :destroy_comment]

    ################################################################################
    def comments_helper_for (klass)
      self.instance_eval {@comment_class = klass}
      include Commentable::ExtendActionController::InstanceMethods
      extend Commentable::ExtendActionController::ClassMethods
      helper(Commentable::ExtendActionView)
    end

    ################################################################################
    module ClassMethods
      ################################################################################
      def comment_methods
        Commentable::ExtendActionController::COMMENT_CONTROLLER_METHODS
      end
    end

    ################################################################################
    module InstanceMethods
      ################################################################################
      def create_comment
        @object = self.class.instance_eval {@comment_class}.find(params[:id])
        
        if @object.respond_to?(:user_can_post_comment) and !@object.user_can_post_comment(current_user)
          render(:nothing => true)
          return
        end

        @comment = @object.comments.build(params[:comment])
        @comment.update_filtered_text(params[:filtered_text], current_user)
        @comment.user = current_user

        if @comment.save
          @object.comment_added(@comment) if @object.respond_to?(:comment_added)
          render(:update) {|p| p.replace(:comment_section, :partial => 'comments/section')}
        else
          render(:update) {|p| p.replace(:comment_form, :partial => 'comments/form')}
        end
      end

      ################################################################################
      def edit_comment
        @object = self.class.instance_eval {@comment_class}.find(params[:id])
        @comment = @object.comments.find(params[:c])

        if @comment.user == current_user or current_user.is_root?
          render(:update) do |page|
            page.replace_html("#{@comment.dom_id}_form", :partial => 'comments/form')
            page.visual_effect(:toggle_slide, "#{@comment.dom_id}_form")
            page.visual_effect(:scroll_to, "#{@comment.dom_id}_form")
          end
        else
          render(:nothing => true)
        end
      end

      ################################################################################
      def update_comment
        @object = self.class.instance_eval {@comment_class}.find(params[:id])
        @comment = @object.comments.find(params[:c])

        if @comment.user == current_user or current_user.is_root?
          @comment.attributes = params[:comment]
          @comment.update_filtered_text(params[:filtered_text], current_user)
  
          if @comment.save
            render(:update) do |page| 
              page.replace(@comment.dom_id, :partial => 'comments/comment')
              page.visual_effect(:scroll_to, @comment.dom_id)
            end
          else
            render(:update) do |page|
              page.replace_html("#{@comment.dom_id}_form", :partial => 'comments/form')
            end
          end
        else
          render(:nothing => true)
        end
      end

      ################################################################################
      def destroy_comment
        @object = self.class.instance_eval {@comment_class}.find(params[:id])
        @comment = @object.comments.find(params[:c])

        if @comment.user == current_user or current_user.is_root?
          @comment.destroy
          render(:update) {|p| p.replace(:comment_section, :partial => 'comments/section')}
        end
      end

    end
  end
end
################################################################################
