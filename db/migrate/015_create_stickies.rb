################################################################################
class CreateStickies < ActiveRecord::Migration
  ################################################################################
  class Policy < ActiveRecord::Base; end

  ################################################################################
  def self.up
    create_table :stickies do |t|
      t.column :stickiepad_id,    :integer
      t.column :stickiepad_type,  :string
      t.column :filtered_text_id, :integer
      t.column :message_type,     :string
      t.column :created_on,       :datetime
      t.column :updated_on,       :datetime
    end

    Policy.new({
      :name        => 'disable_logins',
      :description => 'Only allow site administrators to login, deletes all sessions',
      :value_type  => 'bool',
      :value       => 'false',
    }).save!
  end

  ################################################################################
  def self.down
    drop_table :stickies
    p = Policy.find_by_name('disable_logins') and p.destroy
  end

end
################################################################################
