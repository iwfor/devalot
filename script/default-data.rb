#!/usr/bin/env ruby
################################################################################
require File.dirname(__FILE__) + '/../config/environment'

################################################################################
admin = Account.new({
  :first_name   => 'Admin', 
  :last_name    => 'User', 
  :email        => 'admin@localhost.local'
})

admin.password = 'admin'
admin.save

################################################################################
Project.create({
  :name => 'Site Support',
  :slug => 'support',
})

################################################################################
[
  'Enhancement Request', 
  'Assistance Request', 
  'Minor Problem', 
  'Major Problem', 
  'Critical Problem',

].each do |severity|
  Severity.new(severity).save
end

[
  'Low', 
  'Medium', 
  'High', 
  'Critical',

].each do |priority|
  Priority.new(priority).save
end
