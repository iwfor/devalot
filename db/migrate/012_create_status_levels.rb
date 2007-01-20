################################################################################
class CreateStatusLevels < ActiveRecord::Migration
  ################################################################################
  def self.up
    create_table :status_levels do |t|
      t.column :title,                  :string
      t.column :points,                 :integer, :default => 0
      t.column :can_tag,                :boolean, :default => false
      t.column :can_moderate,           :boolean, :default => false
      t.column :has_visible_content,    :boolean, :default => false
    end
  end

  ################################################################################
  def self.down
    drop_table :status_levels
  end

end
################################################################################
