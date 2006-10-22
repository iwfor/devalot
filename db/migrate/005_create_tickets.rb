################################################################################
class CreateTickets < ActiveRecord::Migration
  ################################################################################
  ANCILLARY_TABLES = [:states, :severities, :priorities]

  ################################################################################
  def self.up
    ################################################################################
    ANCILLARY_TABLES.each do |table|
      create_table table do |t|
        t.column :title,    :string
        t.column :position, :integer
      end
    end

    ################################################################################
    create_table :tickets do |t|
      t.column :project_id,   :integer
      t.column :creator_id,   :integer
      t.column :state_id,     :integer
      t.column :severity_id,  :integer
      t.column :priority_id,  :integer
      t.column :duplicate_of, :integer
      t.column :parent_id,    :integer
      t.column :summary_id,   :integer

      t.column :title,        :string
      t.column :created_on,   :datetime
      t.column :updated_on,   :datetime
    end

    ################################################################################
    create_table :ticket_histories do |t|
      t.column :ticket_id,    :integer
      t.column :user_id,      :integer
      t.column :description,  :text
      t.column :created_on,   :datetime
    end
  end

  ################################################################################
  def self.down
    drop_table(:tickets)
    ANCILLARY_TABLES.each {|t| drop_table(t)}
  end

end
################################################################################
