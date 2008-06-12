class AddReceiveEmailPolicy < ActiveRecord::Migration
  def self.up
    # Add the use_timeline_policy to all currently existing projects.
    # New projects will have this added automatically
    User.find(:all).each do | project |
      project.policies.create({
        :name        => 'receive_email_notification',
        :description => 'Receive emails when changes are made to the projects you are a member of.',
        :value_type  => 'bool',
        :value       => 'true',
      })
    end
  end

  def self.down
    # no removal, not really needed!
  end
end
