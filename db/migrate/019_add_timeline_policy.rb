class AddTimelinePolicy < ActiveRecord::Migration
  def self.up
    # Add the use_timeline_policy to all currently existing projects.
    # New projects will have this added automatically
    Project.find(:all).each do | project |
      project.policies.create({
        :name        => 'use_timeline_system', 
        :description => 'This project provides a timeline of changes',
        :value_type  => 'bool',
        :value       => 'true',
      })    
    end
  end

  def self.down
    # no removal, not really needed!
  end
end
