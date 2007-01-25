################################################################################
#
# Copyright (C) 2006 Peter J Jones (pjones@pmade.com)
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
class ArticlesController < ApplicationController
  ################################################################################
  require_authentication(:except => [:index, :archives, :show])

  ################################################################################
  with_optional_project

  ################################################################################
  tagging_helper_for(Article)
  comments_helper_for(Article)

  ################################################################################
  table_for(Article, :url => :articles_url, :partial => 'admin_table')

  ################################################################################
  before_filter(:lookup_blog)
  before_filter(:calculate_permissions)

  ################################################################################
  def index
    @articles = @blog.articles.find(:all, {
      :order => 'published_on DESC',
      :conditions => {:published => true},
      :limit => 3,
    })
  end

  ################################################################################
  def show
    @article ||= @blog.articles.find_by_permalink(params)
  end

  ################################################################################
  def archive
  end

  ################################################################################
  def admin
    when_authorized(:condition => @can_admin_blog) do
    end
  end
  
  ################################################################################
  def new
    when_authorized(:condition => @can_admin_blog) do
      @article = Article.new
    end
  end
  
  ################################################################################
  def create
    when_authorized(:condition => @can_admin_blog) do
      @article = @blog.articles.build(params[:article])
      @article.user = current_user
      @article.build_body(params[:body])
      @article.body.created_by = current_user
      @article.body.updated_by = current_user

      unless params[:excerpt][:body].blank?
        @article.build_excerpt(params[:excerpt]) 
        @article.excerpt.created_by = current_user
        @article.excerpt.updated_by = current_user
      end

      saved = @article.save

      @article.tags.add(params[:tags]) if saved and !params[:tags].blank?
      conditional_render(saved, :redirect_to => 'admin', :url => articles_url('admin'))
    end
  end

  ################################################################################
  def edit
    when_authorized(:condition => @can_admin_blog) do
      @article = @blog.articles.find(params[:id])
    end
  end

  ################################################################################
  def update
    when_authorized(:condition => @can_admin_blog) do
      things_to_save = [@article]

      @article = @blog.articles.find(params[:id])
      @article.attributes = params[:article]

      @article.body.attributes = params[:body]
      @article.body.updated_by = current_user
      things_to_save << @article.body

      if @article.has_excerpt?
        @article.excerpt.attributes = params[:excerpt]
        @article.excerpt.updated_by = current_user
        things_to_save << @article.excerpt
      end

      conditional_render(things_to_save.all?(&:save), {
        :redirect_to => 'admin', 
        :url => articles_url('admin'),
      })
    end
  end

  ################################################################################
  def publish 
    when_authorized(:conditional => @can_admin_blog) do
      @article = @blog.articles.find(params[:id])
      @article.publish
      @article.save

      render(:update) {|p| p.replace_html(:admin_table, :partial => 'admin_table')}
    end
  end
  ################################################################################
  private

  ################################################################################
  # Allow access to the helpers we created (mostly for the articles_url method)
  include ArticlesHelper

  ################################################################################
  def lookup_blog
    # blog can be taken from article id
    if !params[:id].blank? and params[:year].blank? and params[:id].match(/^\d+$/)
      @article = Article.find_by_permalink(params)
      @blog    = @article.blog
      return
    end

    # explicit blog id was given
    unless params[:blog].blank?
      @blog = Blog.find(params[:blog])
      return
    end

    # if called from a project, use the News blog
    if @project
      @blog = @project.blogs.find('news')
      @main_project_blog = true
      return
    end

    redirect_to(home_url)
    false
  end

  ################################################################################
  def calculate_permissions
    @can_admin_blog = false
  
    case @blog.bloggable_type
    when "Project"
      @can_admin_blog = current_user.can_blog?(@blog.bloggable)
    when "User"
      @can_admin_blog = true if current_user == @blog.bloggable
    end

    true
  end

end
################################################################################
