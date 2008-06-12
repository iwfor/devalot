################################################################################
class CreateStatusLevels < ActiveRecord::Migration
  ##############################################################################
  def self.up
    create_table :status_levels do |t|
      t.string  :title
      t.integer :points,               :default => 0
      t.boolean :can_tag,              :default => false
      t.boolean :can_moderate,         :default => false
      t.boolean :has_visible_content,  :default => false
    end
  end

  ##############################################################################
  def self.down
    drop_table :status_levels
  end

end
################################################################################
