################################################################################
class CreateAccounts < ActiveRecord::Migration
  ################################################################################
  def self.up
    create_table :accounts do |t|
      t.column :first_name,      :string
      t.column :last_name,       :string
      t.column :email,           :string
      t.column :activation_code, :string
      t.column :reset_code,      :string
      t.column :created_on,      :datetime
      t.column :password_salt,   :string
      t.column :password_hash,   :string
      t.column :is_enabled,      :boolean, :default => false
    end

    add_index(:accounts, :email, :unique => true)
    add_index(:accounts, :activation_code)
    add_index(:accounts, :reset_code)
  end

  ################################################################################
  def self.down
    drop_table :accounts
  end

end
################################################################################
