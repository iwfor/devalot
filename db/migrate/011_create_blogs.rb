################################################################################
class CreateBlogs < ActiveRecord::Migration
  ##############################################################################
  def self.up
    create_table :blogs do |t|
      t.integer :bloggable_id
      t.string  :bloggable_type
      t.string  :title
      t.string  :slug
    end

    add_index :blogs, [:bloggable_id, :bloggable_type]
    add_index :blogs, [:bloggable_id, :bloggable_type, :title], :unique => true

    create_table :articles do |t|
      t.integer  :blog_id
      t.integer  :user_id
      t.string   :title
      t.string   :slug
      t.integer  :body_id
      t.integer  :excerpt_id
      t.datetime :created_on
      t.datetime :updated_on
      t.datetime :published_on
      t.boolean  :published,       :default => false
      t.integer  :comments_count,  :default => 0
    end

    add_index :articles, :blog_id
    add_index :articles, :user_id
  end

  ##############################################################################
  def self.down
    drop_table :articles
    drop_table :blogs
  end

end
################################################################################
