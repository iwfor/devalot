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

    ############################################################################
    StatusLevel.new({
      :title                  => 'Level 1 (Moderated)',
      :points                 => 0,
      :can_tag                => false,
      :can_moderate           => false,
      :has_visible_content    => false,
    }).save!

    StatusLevel.new({
      :title                  => 'Level 2 (Tourist)',
      :points                 => 1,
      :can_tag                => true,
      :can_moderate           => false,
      :has_visible_content    => true,
    }).save!

    StatusLevel.new({
      :title                  => 'Level 3 (Civilian)',
      :points                 => 250,
      :can_tag                => true,
      :can_moderate           => true,
      :has_visible_content    => true,
    }).save!

    StatusLevel.new({
      :title                  => 'Level 4 (Citizen)',
      :points                 => 1000,
      :can_tag                => true,
      :can_moderate           => true,
      :has_visible_content    => true,
    }).save!

    StatusLevel.new({
      :title                  => 'Level 5 (Governator)',
      :points                 => 10000,
      :can_tag                => true,
      :can_moderate           => true,
      :has_visible_content    => true,
    }).save!

  end

  ##############################################################################
  def self.down
    drop_table :status_levels
  end

end
################################################################################
