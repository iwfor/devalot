################################################################################
class CreateAttachments < ActiveRecord::Migration
  ##############################################################################
  def self.up
    create_table :attachments do |t|
      t.integer  :attachable_id
      t.string   :attachable_type
      t.integer  :project_id
      t.integer  :user_id
      t.datetime :created_on
      t.datetime :updated_on
      t.string   :filename
      t.boolean  :public,          :default => false
    end
  end

  ##############################################################################
  def self.down
    drop_table :attachments
  end

end
################################################################################
