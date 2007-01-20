#!/usr/bin/env ruby
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
  :title                  => 'Level 2 (Lurker)',
  :points                 => 1,
  :can_tag                => true,
  :can_moderate           => false,
  :has_visible_content    => true,
})
level_2.save!

level_3 = StatusLevel.new({
  :title                  => 'Level 3 (Citizen)',
  :points                 => 150,
  :can_tag                => true,
  :can_moderate           => true,
  :has_visible_content    => true,
})
level_3.save!

level_4 = StatusLevel.new({
  :title                  => 'Level 4 (Resident)',
  :points                 => 1000,
  :can_tag                => true,
  :can_moderate           => true,
  :has_visible_content    => true,
})
level_4.save!

level_5 = StatusLevel.new({
  :title                  => 'Level 5 (Superhero)',
  :points                 => 5000,
  :can_tag                => true,
  :can_moderate           => true,
  :has_visible_content    => true,
})
level_5.save!

################################################################################
admin_user = Account.new({
  :first_name   => 'Admin', 
  :last_name    => 'User', 
  :email        => 'admin@localhost.local',
})

admin_user.enabled = true
admin_user.password = 'admin_pass'
admin_user.save!
admin_user = User.from_account(admin_user)
admin_user.time_zone = 'London'
admin_user.points = level_5.points
admin_user.is_root = true
admin_user.save!

################################################################################
project_attributes = {
  :name    => 'Site Support',
  :slug    => 'support',
  :summary => "Tech-support for this #{APP_NAME} installation"
}

description_attributes = {
  :filter => 'Textile',
  :body   => DefaultPages.fetch('site_support', 'description.html'),
}

support_project = Project.new(project_attributes)
support_project.build_description(description_attributes)
support_project.description.created_by = admin_user
support_project.description.updated_by = admin_user
support_project.save!
support_project.pages.find_by_title('index').tags.add("#{APP_NAME.downcase} help support")

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
Policy.new({
  :name        => 'site_name', 
  :description => "The name of this installation of #{APP_NAME}",
  :value_type  => 'str',
  :value       => APP_NAME,
}).save!

Policy.new({
  :name        => 'site_description', 
  :description => "A short (one line) description for this site",
  :value_type  => 'str',
  :value       => "Software projects that change the world",
}).save!

Policy.new({
  :name        => 'authenticator', 
  :description => 'The user account authentication system to use',
  :value_type  => 'str',
  :value       => 'Standard',
}).save!

Policy.new({
  :name        => 'allow_open_enrollment',
  :description => 'If the current authenticator supports it, enable self-service account creation',
  :value_type  => 'bool',
  :value       => 'true',
}).save!
