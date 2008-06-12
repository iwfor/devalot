################################################################################
class CreatePolicies < ActiveRecord::Migration
  ##############################################################################
  def self.up
    create_table :policies do |t|
      t.integer :policy_id
      t.string  :policy_type
      t.string  :name
      t.string  :description
      t.string  :value
      t.string  :value_type
    end

    add_index :policies, [:policy_id, :policy_type, :name], :unique => true
  end

  ##############################################################################
  def self.down
    drop_table :policies
  end

end
################################################################################
