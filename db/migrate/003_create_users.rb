################################################################################
class CreateUsers < ActiveRecord::Migration
  ##############################################################################
  class User < ActiveRecord::Base
  end

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

    ############################################################################
    User.new(
      :account_id => 1,
      :first_name => 'Admin',
      :last_name  => 'User',
      :email      => 'admin@localhost.local',
      :time_zone  => 'London',
      :points     => 100000,
      :is_root    => true
    ).save!
  end

  ##############################################################################
  def self.down
    drop_table :users
  end

end
################################################################################
