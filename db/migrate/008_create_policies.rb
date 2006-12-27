################################################################################
class CreatePolicies < ActiveRecord::Migration
  ################################################################################
  def self.up
    create_table :policies do |t|
      t.column :policy_id,   :integer
      t.column :policy_type, :string
      t.column :name,        :string
      t.column :description, :string
      t.column :value,       :string
      t.column :value_type,  :string
    end

    add_index(:policies, [:policy_id, :policy_type, :name], :unique => true)
  end

  ################################################################################
  def self.down
    drop_table :policies
  end

end
################################################################################
