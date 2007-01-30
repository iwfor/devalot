#!/usr/bin/env ruby
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
require File.dirname(__FILE__) + '/../config/environment'
require 'highline/import'

################################################################################
def map_user (radiant_user)
  user = User.find_by_email(radiant_user.email)
  user ||= User.find(1)
  user
end

################################################################################
class ConvertRadiant < ActiveRecord::Base
  def self.abstract_class?; true; end
  establish_connection(:radiant)

  class Page < ConvertRadiant
    has_many(:children, :class_name => 'Page', :foreign_key => 'parent_id')
    has_many(:page_parts)
    belongs_to(:created_by, :class_name => 'User', :foreign_key => 'created_by')
    belongs_to(:updated_by, :class_name => 'User', :foreign_key => 'updated_by')
  end

  class PagePart < ConvertRadiant; end
  class User < ConvertRadiant; end
end

################################################################################
def lookup_project
  choose do |menu|
    menu.prompt = "Select a project to place this page in: "

    Project.find(:all).each do |prj|
      menu.choice(prj.name) {return prj}
    end
  end
end

################################################################################
def lookup_blog
  choose do |menu|
    menu.prompt = "Select a blog to place this article in: "

    Blog.find(:all, :order => :title).each do |blog|
      menu.choice("#{blog.bloggable.name}: #{blog.title}") {return blog}
    end
  end
end
################################################################################
def convert_page (page)
  if agree("Is '#{page.title}' a blog article? ")
    convert_article(page)
    return
  end
end

################################################################################
def convert_article (page)
  blog = lookup_blog

  article = blog.articles.build(:title => page.title, :slug => page.slug)
  article.created_on = page.created_at
  article.updated_on = page.updated_at
  article.published_on = page.published_at
  article.published = true
  article.user = map_user(page.created_by)

  body_text = ''
  filter = 'None'

  if part = page.page_parts.find_by_name('body')
    body_text << part.content << "\n"
    filter = part.filter_id unless part.filter_id.blank?
  end

  if part = page.page_parts.find_by_name('extended')
    body_text << part.content << "\n"
    filter = part.filter_id unless part.filter_id.blank?
  end

  article.build_body(:body => body_text, :filter => filter)
  article.body.created_on = article.created_on
  article.body.updated_on = article.updated_on
  article.body.created_by = map_user(page.created_by)
  article.body.updated_by = map_user(page.updated_by || page.created_by)

  article.save!
end
################################################################################

title = ask("Enter the title of the page whose children you want to import: ")
top_page = ConvertRadiant::Page.find_by_title(title)

if top_page.nil?
  puts "can't find page with title: #{title}"
  exit
end

puts "Page '#{title}' has #{top_page.children.size} children"
top_page.children.each {|c| convert_page(c)}
