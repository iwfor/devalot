################################################################################
class CreateAccounts < ActiveRecord::Migration
  ##############################################################################
  def self.up
    create_table :accounts do |t|
      t.string   :first_name
      t.string   :last_name
      t.string   :email
      t.string   :activation_code
      t.string   :reset_code
      t.datetime :created_on
      t.string   :password_salt
      t.string   :password_hash
      t.boolean  :enabled,         :default => false
    end

    add_index(:accounts, :email, :unique => true)
    add_index(:accounts, :activation_code)
    add_index(:accounts, :reset_code)

    ################################################################################
    admin_account = Account.new(
      :first_name   => 'Admin', 
      :last_name    => 'User', 
      :email        => 'admin@localhost.local'
    )

    admin_account.enabled = true
    admin_account.password = 'admin_pass'
    admin_account.save!
  end

  ##############################################################################
  def self.down
    drop_table :accounts
  end

end
################################################################################
