################################################################################
class RemoveFilteredTextFlags < ActiveRecord::Migration
  ##############################################################################
  class StatusLevel < ActiveRecord::Base; end

  ##############################################################################
  def self.up
    # Add columns
    add_column :status_levels, :can_use_radius,    :boolean, :default => false
    add_column :status_levels, :can_skip_sanitize, :boolean, :default => false

    # Update existing rows.  This needs to be done in many operations because
    # ActiveRecord::Base.sanitize_sql will connect the update columns with an
    # AND instead of a comma.  In addition, we need to use the array form of
    # sanitize_sql otherwise the column names include the table name, which
    # doesn't seem to work in update statements.
    StatusLevel.update_all ['can_use_radius = ?',    false]
    StatusLevel.update_all ['can_skip_sanitize = ?', false]
    StatusLevel.update_all ['can_use_radius = ?',    true], ['points >= ?', 1000]
    StatusLevel.update_all ['can_skip_sanitize = ?', true], ['points >= ?', 10000]
  end

  ##############################################################################
  def self.down
    remove_column :status_levels, :can_use_radius
    remove_column :status_levels, :can_skip_sanitize
  end

end
################################################################################
