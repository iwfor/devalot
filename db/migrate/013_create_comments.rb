################################################################################
class CreateComments < ActiveRecord::Migration
  ##############################################################################
  def self.up
    create_table :comments do |t|
      t.integer  :commentable_id
      t.string   :commentable_type
      t.integer  :user_id
      t.integer  :filtered_text_id
      t.datetime :created_on
      t.datetime :updated_on
      t.boolean  :visible
    end
  end

  ##############################################################################
  def self.down
    drop_table :comments
  end

end
################################################################################
