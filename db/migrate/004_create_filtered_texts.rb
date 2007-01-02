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
      t.column :version,       :integer
      t.column :lock_version,  :integer, :default => 0
    end

    FilteredText.create_versioned_table
  end

  ################################################################################
  def self.down
    drop_table :filtered_texts
    FilteredText.drop_versioned_table
  end

end
################################################################################
