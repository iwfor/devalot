class CreateWatchersTable < ActiveRecord::Migration
  def self.up
    create_table :watchers do |t|
      t.integer :target_id
      t.string  :target_type
      t.integer :user_id
      t.timestamps
    end

    add_index :watchers, [:user_id, :target_type, :target_id]
    add_index :watchers, [:target_type, :target_id]
  end

  def self.down
    drop_table :watchers
  end
end
