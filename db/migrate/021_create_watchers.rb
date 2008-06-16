class CreateWatchers < ActiveRecord::Migration
  def self.up
    create_table :watchers do |t|
      t.integer :watchable_id
      t.string  :watchable_type
      t.integer :user_id
      t.timestamps
    end

    add_index :watchers, [:user_id, :watchable_type, :watchable_id]
    add_index :watchers, [:watchable_type, :watchable_id]
  end

  def self.down
    drop_table :watchers
  end
end
