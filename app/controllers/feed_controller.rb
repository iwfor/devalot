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
      @blog = @project.blogs.find_by_slug(params[:blog])
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
  def tickets
    feed_options = {
      :class => Ticket, # for empty feeds
      :feed  => {},

      :item => {
        :guid => lambda {|h| "#{h.ticket_id}-#{h.id}"},
        :link => lambda {|h| url_for(url_for_ticket(h.ticket).merge(:only_path => false))},
        :title => lambda {|h| "Ticket #{h.ticket.id}: #{h.ticket.title} (Change by #{h.user.name})"},
        :description => lambda {|h| render_to_string(:partial => 'tickets/history_for_rss', :locals => {:history => h})},
      }
    }

    if (@project.rss_id.to_s.upcase != params[:code].strip.upcase)
      render(:nothing => true)
      return
    end

    find_options = {
      :order      => 'ticket_histories.created_on DESC',
      :limit      => Policy.lookup(:feed_articles).value,
    }

    if params[:id] != 'all'
      @ticket = @project.tickets.find(params[:id])
      @histories = @ticket.histories.find(:all, find_options)
      feed_options[:feed][:link] = url_for(url_for_ticket(@ticket), :only_path => false)
      feed_options[:feed][:title] = "#{@project.name} Ticket #{@ticket.id}: #{@ticket.title}"
      feed_options[:feed][:description] = feed_options[:feed][:title]
    else
      find_options.update(:include => :ticket, :conditions => ['tickets.project_id = ?', @project.id])
      @histories = TicketHistory.find(:all, find_options)
      feed_options[:feed][:link] = url_for(url_for_ticket_list, :only_path => false)
      feed_options[:feed][:title] = "#{@project.name} Tickets"
      feed_options[:feed][:description] = feed_options[:feed][:title]
    end

    respond_to do |format|
      format.rss  { render_rss_feed_for(@histories, feed_options) }
      format.atom { render_atom_feed_for(@histories, feed_options) }
    end
  end

  ################################################################################
  private

  ################################################################################
  include ArticlesHelper
  include TicketsHelper

end
################################################################################
