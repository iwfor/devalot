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

################################################################################
all_permissions = {}

Role.column_names.each do |row|
  next unless row.match(/^can_/)
  all_permissions.store(row.to_sym, true)
end

admin_role = Role.new({
  :title => 'Administrator',
}.merge(all_permissions))
admin_role.save!

developer_role = Role.new({
  :title                    => 'Developer',
  :can_edit_attachments     => true,
  :can_attach_to_pages      => true,
  :can_create_pages         => true,
  :can_edit_pages           => true,
  :can_edit_tickets         => true,
  :can_blog                 => true,
})
developer_role.save!

page_editor_role = Role.new({
  :title                    => 'Assistant',
  :can_create_pages         => true,
  :can_edit_pages           => true,
})
page_editor_role.save!

################################################################################
level_1 = StatusLevel.new({
  :title                  => 'Level 1 (Moderated)',
  :points                 => 0,
  :can_tag                => false,
  :can_moderate           => false,
  :has_visible_content    => false,
})
level_1.save!

level_2 = StatusLevel.new({
  :title                  => 'Level 2 (Tourist)',
  :points                 => 1,
  :can_tag                => true,
  :can_moderate           => false,
  :has_visible_content    => true,
})
level_2.save!

level_3 = StatusLevel.new({
  :title                  => 'Level 3 (Civilian)',
  :points                 => 250,
  :can_tag                => true,
  :can_moderate           => true,
  :has_visible_content    => true,
})
level_3.save!

level_4 = StatusLevel.new({
  :title                  => 'Level 4 (Citizen)',
  :points                 => 1000,
  :can_tag                => true,
  :can_moderate           => true,
  :has_visible_content    => true,
})
level_4.save!

level_5 = StatusLevel.new({
  :title                  => 'Level 5 (Governator)',
  :points                 => 10000,
  :can_tag                => true,
  :can_moderate           => true,
  :has_visible_content    => true,
})
level_5.save!

################################################################################
admin_account = Account.new({
  :first_name   => 'Admin', 
  :last_name    => 'User', 
  :email        => 'admin@localhost.local',
})

admin_account.enabled = true
admin_account.password = 'admin_pass'
admin_account.save!
admin_user = User.from_account(admin_account)
admin_user.time_zone = 'London'
admin_user.points = level_5.points
admin_user.is_root = true
admin_user.build_description(:body => DefaultPages.fetch('users', 'admin_desc.html'), :filter => 'Textile')
admin_user.save!

################################################################################
project_attributes = {
  :name    => 'Site Support',
  :slug    => 'support',
  :summary => "Tech-support for this #{APP_NAME} installation"
}

support_project = Project.new(project_attributes)
support_project.description = DefaultPages.fetch('site_support', 'description.html')
support_project.description_filter = 'Textile'
support_project.nav_content = DefaultPages.fetch('site_support', 'nav_content.html')
support_project.save!

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

################################################################################
admin_user.positions.build(:project => support_project, :role => admin_role)
admin_user.save!

################################################################################
[
  'Enhancement Request', 
  'Assistance Request', 
  'Minor Problem', 
  'Major Problem', 
  'Critical Problem',

].each do |severity|
  Severity.new(severity).save!
end

[
  'Low', 
  'Medium', 
  'High', 
  'Critical',

].each do |priority|
  Priority.new(priority).save!
end

################################################################################
# policies
Policy.new(
  :name        => 'site_name', 
  :description => "The name of this installation of #APP_NAME",
  :value_type  => 'str',
  :value       => APP_NAME
).save!

Policy.new(
  :name        => 'site_description', 
  :description => "A short (one line) description for this site",
  :value_type  => 'str',
  :value       => "Software projects that change the world"
).save!

Policy.new(
  :name        => 'front_page_articles', 
  :description => "The number of blog articles to display on the front page",
  :value_type  => 'int',
  :value       => '5'
).save!

Policy.new(
  :name        => 'feed_articles', 
  :description => "The number of blog articles to place in the RSS/Atom feeds",
  :value_type  => 'int',
  :value       => '10'
).save!

Policy.new(
  :name        => 'authenticator', 
  :description => 'The user account authentication system to use',
  :value_type  => 'str',
  :value       => 'Standard'
).save!

Policy.new(
  :name        => 'allow_open_enrollment',
  :description => 'If the current authenticator supports it, enable self-service account creation',
  :value_type  => 'bool',
  :value       => 'true'
).save!

Policy.new(
  :name        => 'bot_from_email',
  :description => 'The from address for mail sent by a bot that can\'t accept reply mail',
  :value_type  => 'str',
  :value       => 'noreply@localhost.local'
).save!

Policy.new(
  :name        => 'moderation_feed_code',
  :description => 'A secret code used by RSS/Atom feed readers to access the list of moderated users',
  :value_type  => 'str',
  :value       => Policy.random_code
).save!

Policy.new(
  :name => 'host',
  :description => 'Domain name for emailed URLs',
  :value => 'fill.me.in',
  :value_type => 'str'
).save!

Policy.new(
  :name => 'port',
  :description => 'Port for emailed URLs',
  :value => '80',
  :value_type => 'int'
).save!

Policy.new(
  :name => 'pdf_generator',
  :description => 'Enable PDF generator.  Requires HTMLDOC command line tool installed.',
  :value => '80',
  :value_type => 'bool'
).save!
