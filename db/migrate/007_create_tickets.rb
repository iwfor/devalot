################################################################################
class CreateTickets < ActiveRecord::Migration
  ##############################################################################
  ANCILLARY_TABLES = [:severities, :priorities]

  ##############################################################################
  def self.up
    ############################################################################
    ANCILLARY_TABLES.each do |table|
      create_table table do |t|
        t.string  :title
        t.integer :position
      end
    end

    ############################################################################
    create_table :tickets do |t|
      t.integer  :project_id
      t.integer  :creator_id
      t.integer  :severity_id
      t.integer  :priority_id
      t.integer  :duplicate_of_id
      t.integer  :parent_id
      t.integer  :summary_id
      t.integer  :assigned_to_id
      t.string   :title
      t.integer  :state
      t.boolean  :visible
      t.datetime :created_on
      t.datetime :updated_on
      t.integer  :comments_count,  :default => 0
    end

    ############################################################################
    create_table :ticket_histories do |t|
      t.integer  :ticket_id
      t.integer  :user_id
      t.text     :description
      t.datetime :created_on
    end
  end

  ##############################################################################
  def self.down
    drop_table :ticket_histories
    drop_table :tickets
    ANCILLARY_TABLES.each {|t| drop_table t}
  end

end
################################################################################
