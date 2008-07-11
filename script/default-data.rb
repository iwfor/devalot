#!/usr/bin/env ruby
################################################################################
#
# Copyright (C) 2008 Isaac Foraker <isaac@noscience.net>, all rights reserved.
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

admin_user = User.find(1)
admin_role = Role.find(1)

############################################################################
support_project = Project.new(
  :name               => 'Site Support',
  :slug               => 'support',
  :summary            => "Tech-support for this #{APP_NAME} installation",
  :description        => DefaultPages.fetch('site_support', 'description.html'),
  :description_filter => 'Textile',
  :nav_content        => DefaultPages.fetch('site_support', 'nav_content.html')
)
support_project.save!

############################################################################
admin_user.positions.build(:project => support_project, :role => admin_role)
admin_user.save!

# Create Support index page
page = support_project.pages.find_by_title('index')
page.slug = 'index'
page.tags.add("#{APP_NAME.downcase} help support")
page.body = DefaultPages.fetch('site_support', 'index.html')
page.body_filter = 'Textile'
page.created_by = admin_user
page.updated_by = admin_user
page.save!

# Create FAQ page
page = support_project.pages.build(:title => 'Frequently Asked Questions', :toc_element => 'h2')
page.slug = 'faq'
page.body = DefaultPages.fetch('site_support', 'faq.html')
page.body_filter = 'Textile'
page.created_by = admin_user
page.updated_by = admin_user
page.save!

# Create Moderation Levels page
page = support_project.pages.build(:title => 'Moderation Levels', :toc_element => 'h2')
page.slug = 'moderation_levels'
page.body = DefaultPages.fetch('site_support', 'moderation_levels.html')
page.body_filter = 'Textile'
page.created_by = admin_user
page.updated_by = admin_user
page.save!

