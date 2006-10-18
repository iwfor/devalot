################################################################################
class CreateProjects < ActiveRecord::Migration
  ################################################################################
  # we don't need a drop_table, this is the first migration ;)
  def self.up
    create_table :projects do |t|
      t.column :name,       :string
      t.column :slug,       :string
      t.column :created_on, :datetime
    end

    add_index(:projects, :slug, :unique => true)
  end

end
################################################################################
