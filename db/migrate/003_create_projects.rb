################################################################################
class CreateProjects < ActiveRecord::Migration
  ################################################################################
  def self.up
    ################################################################################
    create_table :projects do |t|
      t.column :name,       :string
      t.column :slug,       :string
      t.column :created_on, :datetime
    end

    add_index(:projects, :slug, :unique => true)

    ################################################################################
    create_table :project_roles do |t|
      t.column :name,                     :string
      t.column :position,                 :integer
      t.column :can_create_pages,         :boolean, :default => false
      t.column :can_edit_pages,           :boolean, :default => false
      t.column :can_add_users,            :boolean, :default => false
      t.column :can_demote_users,         :boolean, :default => false
      t.column :can_assign_tickets,       :boolean, :default => false
      t.column :can_close_other_tickets,  :boolean, :default => false
    end

    ################################################################################
    create_table :projects_users do |t|
      t.column :project_id,       :integer
      t.column :user_id,          :integer
      t.column :project_role_id,  :integer
    end

  end

  ################################################################################
  def self.down
    drop_table :projects_users
    drop_table :project_roles
    drop_table :projects
  end

end
################################################################################
