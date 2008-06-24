class CreateHistoryEntries < ActiveRecord::Migration
  def self.up
    create_table :history_entries do |t|
      t.integer    :history_id,  :nil => :false
      t.string     :action
      t.string     :field
      t.text       :value
      t.string     :value_type
    end

    add_index :history_entries, [:history_id, :field]
  end

  def self.down
    drop_table :history_entries
  end
end
