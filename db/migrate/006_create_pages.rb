################################################################################
class CreatePages < ActiveRecord::Migration
  ################################################################################
  def self.up
    create_table :pages do |t|
      t.integer :project_id
      t.integer :filtered_text_id
      t.string  :title
      t.string  :toc_element
      t.integer :comments_count,   :default => 0
    end

    add_index :pages, [:project_id, :title], :unique => true
  end

  ################################################################################
  def self.down
    drop_table :pages
  end

end
################################################################################
