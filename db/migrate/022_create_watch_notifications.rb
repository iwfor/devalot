# The watch_notifications table acts as a queue for email watch notifications
# that need to be sent.
class CreateWatchNotifications < ActiveRecord::Migration
  def self.up
    create_table :watch_notifications do |t|
      t.integer    :watcher_id
      t.integer    :user_id
      t.integer    :count,           :default => 1
      t.timestamps
    end

    add_index :watch_notifications, [:user_id, :watcher_id]
    add_index :watch_notifications, [:watcher_id, :user_id]
  end

  def self.down
    drop_table :watch_notifications
  end
end
