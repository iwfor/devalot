################################################################################
class CreateFilteredTexts < ActiveRecord::Migration
  ################################################################################
  def self.up
    create_table :filtered_texts do |t|
      t.column :body,          :text
      t.column :filter,        :string
      t.column :created_on,    :datetime
      t.column :updated_on,    :datetime
      t.column :created_by_id, :integer
      t.column :updated_by_id, :integer
    end
  end

  ################################################################################
  def self.down
    drop_table :filtered_texts
  end

end
################################################################################
