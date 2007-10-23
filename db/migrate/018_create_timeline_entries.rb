class CreateTimelineEntries < ActiveRecord::Migration
  def self.up
    create_table :timeline_entries do |t|
      t.column :project_id, :integer, :nil => false
      t.column :parent_id, :integer, :nil => false
      t.column :parent_type, :string, :nil => false
      # t.column :parent_sub_type, :string
      t.column :user_id, :integer
      t.column :change, :string, :nil => false
      t.column :description, :text
      t.column :comment, :text
      t.column :created_at, :datetime
      t.column :updated_at, :timestamp
    end
  end

  def self.down
    drop_table :timeline_entries
  end
end
