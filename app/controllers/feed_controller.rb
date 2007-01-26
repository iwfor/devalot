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
class FeedController < ApplicationController
  ################################################################################
  session(:off)

  ################################################################################
  with_optional_project

  ################################################################################
  def articles
    find_options = {
      :conditions => {:published => true},
      :order => 'published_on DESC',
      :limit => Policy.lookup(:feed_articles).value,
    }

    feed_options = {
      :class => Article, # for empty feeds
      :feed  => {},

      :item => {
        :pub_date => :published_on,
        :link => lambda {|a| url_for(articles_url('show', a).merge(:only_path => false))},
        :description => lambda {|a| render_to_string(:partial => 'articles/article_for_list', :locals => {:article => a})},
      }
    }

    if @project
      @blog = @project.blogs.find(params[:blog])
      @articles = @blog.articles.find(:all, find_options)
      feed_options[:feed][:title] = "#{@project.name} #{@blog.title}"
    elsif params[:blog] == 'all'
      @articles = Article.find(:all, find_options)
      feed_options[:feed][:title] = Policy.lookup(:site_name).value + ' Articles'
      feed_options[:feed][:link] = home_url(:only_path => false)
    elsif @blog = Blog.find(params[:blog], :conditions => {:bloggable_type => 'User'})
      @articles = @blog.articles.find(:all, find_options)
      feed_options[:feed][:title] = "#{@blog.title} Articles from #{@blog.bloggable.name}"
    end

    feed_options[:feed][:link] ||= url_for(articles_url('index').merge(:only_path => false))
    feed_options[:feed][:description] ||= "Blog Articles"

    respond_to do |format|
      format.rss  { render_rss_feed_for(@articles, feed_options) }
      format.atom { render_atom_feed_for(@articles, feed_options) }
    end
  end

  ################################################################################
  private

  ################################################################################
  include ArticlesHelper

end
################################################################################
