################################################################################
class CreatePages < ActiveRecord::Migration
  ################################################################################
  def self.up
    create_table :pages do |t|
      t.column :project_id,       :integer
      t.column :filtered_text_id, :integer
      t.column :title,            :string
      t.column :toc_element,      :string
      t.column :comments_count,   :integer, :default => 0
    end

    add_index(:pages, [:project_id, :title], :unique => true)
  end

  ################################################################################
  def self.down
    drop_table(:pages)
  end

end
################################################################################
