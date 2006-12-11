################################################################################
class AddTagging < ActiveRecord::Migration
  ################################################################################
  def self.up
    ################################################################################
    create_table :tags do |t|
      t.column :name,            :string
      t.column :reference_count, :integer, :default => 0
    end

    add_index(:tags, :name, :unique => true)

    ################################################################################
    create_table :taggings do |t|
      t.column :taggable_id,   :integer
      t.column :taggable_type, :string
      t.column :tag_id,        :integer
    end

    add_index(:taggings, [:taggable_id, :taggable_type])
    add_index(:taggings, :tag_id)
  end

  ################################################################################
  def self.down
    drop_table :taggings
    drop_table :tags
  end

end
################################################################################
