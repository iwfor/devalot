################################################################################
class CreateAttachments < ActiveRecord::Migration
  ################################################################################
  def self.up
    create_table :attachments do |t|
      t.column :attachable_id,   :integer
      t.column :attachable_type, :string
      t.column :project_id,      :integer
      t.column :user_id,         :integer
      t.column :created_on,      :datetime
      t.column :updated_on,      :datetime
      t.column :filename,        :string
      t.column :public,          :boolean, :default => false
    end
  end

  ################################################################################
  def self.down
    drop_table :attachments
  end

end
################################################################################
