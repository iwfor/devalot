################################################################################
class CreatePages < ActiveRecord::Migration
  ##############################################################################
  def self.up
    create_table :pages do |t|
      t.integer :project_id
      t.string  :slug
      t.text    :body
      t.string  :body_filter
      t.string  :title
      t.string  :toc_element
      t.integer :comments_count,   :default => 0
      t.integer :created_by_id
      t.integer :updated_by_id
      t.timestamps
    end

    add_index :pages, [:project_id, :title], :unique => true

  end

  ##############################################################################
  def self.down
    drop_table :pages
  end

end
################################################################################
