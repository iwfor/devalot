class CreateTimelineEntries < ActiveRecord::Migration
  def self.up
    create_table :timeline_entries do |t|
      t.integer   :project_id,      :nil => false
      t.integer   :parent_id,       :nil => false
      t.string    :parent_type,     :nil => false
      #t.string   :parent_sub_type
      t.integer   :user_id
      t.string    :change,          :nil => false
      t.text      :description
      t.text      :comment
      t.datetime  :created_at
      t.timestamp :updated_at
    end
  end

  def self.down
    drop_table :timeline_entries
  end
end
