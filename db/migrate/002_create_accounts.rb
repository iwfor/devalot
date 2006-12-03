################################################################################
class CreateAccounts < ActiveRecord::Migration
  ################################################################################
  def self.up
    create_table :accounts do |t|
      t.column :first_name,     :string
      t.column :last_name,      :string
      t.column :email,          :string
      t.column :password_salt,  :string
      t.column :password_hash,  :string
    end

    add_index(:accounts, :email, :unique => true)
  end

  ################################################################################
  def self.down
    drop_table :accounts
  end

end
################################################################################
