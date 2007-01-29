################################################################################
class CreateProjects < ActiveRecord::Migration
  ################################################################################
  def self.up
    ################################################################################
    create_table :projects do |t|
      t.column :name,           :string
      t.column :slug,           :string
      t.column :summary,        :string
      t.column :description_id, :integer
      t.column :nav_content_id, :integer
      t.column :icon,           :string
      t.column :created_on,     :datetime
      t.column :rss_id,         :string
      t.column :public,         :boolean, :default => true
    end

    add_index(:projects, :slug, :unique => true)
    add_index(:projects, :rss_id, :unique => true)

    ################################################################################
    create_table :roles do |t|
      t.column :title,                    :string
      t.column :position,                 :integer
      t.column :can_admin_project,        :boolean, :default => false
      t.column :can_edit_users,           :boolean, :default => false
      t.column :can_edit_attachments,     :boolean, :default => false
      t.column :can_attach_to_pages,      :boolean, :default => false
      t.column :can_create_pages,         :boolean, :default => false
      t.column :can_edit_pages,           :boolean, :default => false
      t.column :can_edit_tickets,         :boolean, :default => false
      t.column :can_admin_blog,           :boolean, :default => false
      t.column :can_blog,                 :boolean, :default => false
    end

    ################################################################################
    create_table :positions do |t|
      t.column :project_id, :integer
      t.column :user_id,    :integer
      t.column :role_id,    :integer
      t.column :created_on, :datetime
    end

  end

  ################################################################################
  def self.down
    drop_table :positions
    drop_table :roles
    drop_table :projects
  end

end
################################################################################
