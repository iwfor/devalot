################################################################################
class CreateUsers < ActiveRecord::Migration
  ################################################################################
  def self.up
    create_table :users do |t|
      t.column :account_id,     :integer
      t.column :first_name,     :string
      t.column :last_name,      :string
      t.column :email,          :string
      t.column :time_zone,      :string
      t.column :time_format,    :string
      t.column :description_id, :integer
      t.column :avatar_image,   :string
      t.column :gravatar_id,    :string
      t.column :created_on,     :datetime
      t.column :last_login,     :datetime
      t.column :enabled,        :boolean, :default => true
      t.column :points,         :integer, :default => 0
      t.column :is_root,        :boolean, :default => false
    end

    add_index(:users, :account_id, :unique => true)
    add_index(:users, :email, :unique => true)
  end

  ################################################################################
  def self.down
    drop_table :users
  end

end
################################################################################
