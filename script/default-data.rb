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
  :can_create_pages         => true,
  :can_edit_pages           => true,
  :can_edit_tickets         => true,
  :can_close_other_tickets  => true,
})
developer_role.save!

page_editor_role = Role.new({
  :title                    => 'Assistant',
  :can_create_pages         => true,
  :can_edit_pages           => true,
})
page_editor_role.save!

################################################################################
admin_user = Account.new({
  :first_name   => 'Admin', 
  :last_name    => 'User', 
  :email        => 'admin@localhost.local'
})

admin_user.password = 'admin'
admin_user.save!
admin_user = User.from_account(admin_user)
admin_user.is_root = true
admin_user.save!

################################################################################
project_attributes = {
  :name    => 'Site Support',
  :slug    => 'support',
  :summary => "Tech-support for this #{APP_NAME} installation"
}

body = <<EOT
The *site support project* provides end-user support for this installation of <r:#{APP_NAME.downcase}/>.

Having problems with your account, or don't know where to ask a question?  You've come to the right place.  This project has the resources to help you track down the solution.  Start with these suggestions:

* Read the [[frequently ask questions:faq]]
* Open a <r:tickets:link title="support ticket"/>
EOT

description_attributes = {
  :filter => 'Textile',
  :body   => body,
}

support_project = Project.new(admin_user, project_attributes, description_attributes)
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
  :name        => 'users_can_create_projects', 
  :description => 'Allow a registered user to request that a project be created',
  :value_type  => 'bool',
  :value       => 'false',
}).save!

Policy.new({
  :name        => 'allow_open_enrollment',
  :description => 'If the current authenticator supports it, enable self-service account creation',
  :value_type  => 'bool',
  :value       => 'true',
}).save!
