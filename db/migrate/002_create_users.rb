################################################################################
class CreateUsers < ActiveRecord::Migration
  ################################################################################
  def self.up
    create_table :users do |t|
      t.column :account_id,     :integer
      t.column :first_name,     :string
      t.column :last_name,      :string
      t.column :email,          :string
    end

    add_index(:users, :account_id, :unique => true)
  end

  ################################################################################
  def self.down
    drop_table :users
  end

end
################################################################################
