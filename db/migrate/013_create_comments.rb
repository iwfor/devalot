################################################################################
class CreateComments < ActiveRecord::Migration
  ################################################################################
  def self.up
    create_table :comments do |t|
      t.column :commentable_id,   :integer
      t.column :commentable_type, :string
      t.column :user_id,          :integer
      t.column :filtered_text_id, :integer
      t.column :created_on,       :datetime
      t.column :updated_on,       :datetime
      t.column :visible,          :boolean
    end
  end

  ################################################################################
  def self.down
    drop_table :comments
  end

end
################################################################################
