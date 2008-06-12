################################################################################
class CreateUsers < ActiveRecord::Migration
  ##############################################################################
  def self.up
    create_table :users do |t|
      t.integer  :account_id
      t.string   :first_name
      t.string   :last_name
      t.string   :email
      t.string   :time_zone
      t.string   :time_format
      t.integer  :description_id
      t.string   :avatar_image
      t.string   :gravatar_id
      t.datetime :created_on
      t.datetime :last_login
      t.boolean  :enabled,        :default => true
      t.integer  :points,         :default => 0
      t.boolean  :is_root,        :default => false
    end

    add_index :users, :account_id, :unique => true
    add_index :users, :email, :unique => true
  end

  ##############################################################################
  def self.down
    drop_table :users
  end

end
################################################################################
