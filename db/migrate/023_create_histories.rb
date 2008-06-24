class CreateHistories < ActiveRecord::Migration
  def self.up
    create_table :histories do |t|
      t.integer    :project_id
      t.integer    :object_id
      t.string     :object_type
      t.integer    :user_id
      t.string     :action
      t.datetime   :created_at
    end

    add_index :histories, [:object_id, :object_type, :created_at]
    add_index :histories, [:project_id, :created_at]
    add_index :histories, [:user_id, :created_at]
  end

  def self.down
    drop_table :histories
  end
end
