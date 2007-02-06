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
class Article < ActiveRecord::Base
  ################################################################################
  attr_accessible(:title, :slug, :published, :published_on, :created_on, :updated_on)

  ################################################################################
  delegate(:year, :month, :day, :to => :published_on)

  ################################################################################
  # Must have a title, and slug, and slug must be unique
  validates_presence_of(:title)
  validates_presence_of(:slug)
  validates_uniqueness_of(:slug, :scope => [:blog_id, :published_on])

  ################################################################################
  # What blog did this come from?
  belongs_to(:blog)

  ################################################################################
  # The author of the article
  belongs_to(:user)

  ################################################################################
  belongs_to(:body,    :class_name => 'FilteredText', :foreign_key => :body_id)
  belongs_to(:excerpt, :class_name => 'FilteredText', :foreign_key => :excerpt_id)

  ################################################################################
  has_many(:comments, :as => :commentable)

  ################################################################################
  acts_as_taggable

  ################################################################################
  def self.find_by_permalink (params)
    if params[:year].blank? and params[:id].match(/^\d+$/)
      return self.find(params[:id])
    end

    start_of_day = Time.mktime(params[:year].to_i, params[:month].to_i, params[:day].to_i)
    end_of_day   = start_of_day + 1.day - 1

    conditions = ['slug = ? and published_on between ? and ?', params[:id], start_of_day, end_of_day]
    self.find(:first, :conditions => conditions) or raise "can't find article with permalink #{params.inspect}"
  end

  ################################################################################
  def self.find_in_month (year, month)
    start_of_month = Time.mktime(year.to_i, month.to_i, 1)
    conditions = ['published_on between ? and ?', start_of_month, start_of_month.end_of_month]
    self.find(:all, :conditions => conditions)
  end

  ################################################################################
  def self.find_public_and_published (limit)
    joins = "left join blogs on articles.blog_id = blogs.id "
    joins << "left join projects on blogs.bloggable_id = projects.id and blogs.bloggable_type = 'Project'"
    
    self.find(:all, {
      :select     => 'articles.*',
      :conditions => ['articles.published = ? and (projects.public is null or projects.public = ?)', true, true],
      :joins => joins,
      :order => 'articles.published_on DESC',
      :limit => limit,
    })
  end

  ################################################################################
  # Toggle the published status
  def publish
    if self.published?
      self.published = false
      self.published_on = nil
    else
      self.published = true
      self.published_on = Time.now
    end
  end

  ################################################################################
  # Called when someone tags this article
  def tagging_added (tagging)
    if Project === self.blog.bloggable
      tagging.project_id = self.blog.bloggable.id
    end
  end

  ################################################################################
  private

  ################################################################################
  before_create do |article|
    article.body.allow_caching = true if article.body
    article.excerpt.allow_caching = true if article.excerpt
  end

  ################################################################################
  before_update do |article|
    if article.body and !article.body.allow_caching?
      article.body.allow_caching = true
      article.body.save
    end

    if article.excerpt and !article.excerpt.allow_caching?
      article.excerpt.allow_caching = true
      article.excerpt.save
    end
  end

end
################################################################################
