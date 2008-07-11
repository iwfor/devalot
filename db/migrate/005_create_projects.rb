################################################################################
class CreateProjects < ActiveRecord::Migration
  ##############################################################################
  def self.up
    ############################################################################
    create_table :projects do |t|
      t.string   :name
      t.string   :slug
      t.string   :summary
      t.text     :description
      t.string   :description_filter
      t.text     :nav_content
      t.string   :nav_content_filter
      t.string   :icon
      t.datetime :created_on
      t.string   :rss_id
      t.boolean  :public,         :default => true
      t.datetime :updated_on
    end

    add_index :projects, :slug, :unique => true
    add_index :projects, :rss_id, :unique => true

    ############################################################################
    create_table :roles do |t|
      t.string  :title
      t.integer :position
      t.boolean :can_admin_project,     :default => false
      t.boolean :can_edit_users,        :default => false
      t.boolean :can_edit_attachments,  :default => false
      t.boolean :can_attach_to_pages,   :default => false
      t.boolean :can_create_pages,      :default => false
      t.boolean :can_edit_pages,        :default => false
      t.boolean :can_edit_tickets,      :default => false
      t.boolean :can_admin_blog,        :default => false
      t.boolean :can_blog,              :default => false
    end

    ############################################################################
    create_table :positions do |t|
      t.integer  :project_id
      t.integer  :user_id
      t.integer  :role_id
      t.datetime :created_on
    end

    ############################################################################
    all_permissions = {}

    Role.column_names.each do |row|
      next unless row.match(/^can_/)
      all_permissions.store(row.to_sym, true)
    end

    Role.new({
      :title => 'Administrator',
    }.merge(all_permissions)).save!

    Role.new({
      :title                    => 'Developer',
      :can_edit_attachments     => true,
      :can_attach_to_pages      => true,
      :can_create_pages         => true,
      :can_edit_pages           => true,
      :can_edit_tickets         => true,
      :can_blog                 => true,
    }).save!

    Role.new({
      :title                    => 'Assistant',
      :can_create_pages         => true,
      :can_edit_pages           => true,
    }).save!

  end

  ##############################################################################
  def self.down
    drop_table :positions
    drop_table :roles
    drop_table :projects
  end

end
################################################################################
