################################################################################
class CreateStickies < ActiveRecord::Migration
  ##############################################################################
  class Policy < ActiveRecord::Base; end

  ##############################################################################
  def self.up
    create_table :stickies do |t|
      t.integer  :stickiepad_id
      t.string   :stickiepad_type
      t.integer  :filtered_text_id
      t.string   :message_type
      t.datetime :created_on
      t.datetime :updated_on
    end

    Policy.new({
      :name        => 'disable_logins',
      :description => 'Only allow site administrators to login, deletes all sessions',
      :value_type  => 'bool',
      :value       => 'false',
    }).save!
  end

  ##############################################################################
  def self.down
    drop_table :stickies
    p = Policy.find_by_name('disable_logins') and p.destroy
  end

end
################################################################################
