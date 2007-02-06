################################################################################
class AddProjectToTagging < ActiveRecord::Migration
  ################################################################################
  def self.up
    add_column(:taggings, :project_id, :integer)

    Tagging.find(:all).each do |tagging|
      tagging.taggable.tagging_added(tagging) if tagging.taggable.respond_to?(:tagging_added)
      tagging.save!
    end
  end

  ################################################################################
  def self.down
  end

end
################################################################################
