################################################################################
class AddTagging < ActiveRecord::Migration
  ##############################################################################
  def self.up
    ############################################################################
    create_table :tags do |t|
      t.string  :name
      t.integer :reference_count,  :default => 0
    end

    add_index(:tags, :name, :unique => true)

    ############################################################################
    create_table :taggings do |t|
      t.integer  :taggable_id
      t.string   :taggable_type
      t.integer  :tag_id
      t.datetime :created_on
    end

    add_index :taggings, [:taggable_id, :taggable_type]
    add_index :taggings, :tag_id
  end

  ##############################################################################
  def self.down
    drop_table :taggings
    drop_table :tags
  end

end
################################################################################
