################################################################################
class CreateBlogs < ActiveRecord::Migration
  ################################################################################
  def self.up
    create_table :blogs do |t|
      t.column :bloggable_id,   :integer
      t.column :bloggable_type, :string
      t.column :title,          :string
      t.column :slug,           :string
    end

    add_index(:blogs, [:bloggable_id, :bloggable_type])
    add_index(:blogs, [:bloggable_id, :bloggable_type, :title], :unique => true)

    create_table :articles do |t|
      t.column :blog_id,          :integer
      t.column :user_id,          :integer
      t.column :title,            :string
      t.column :slug,             :string
      t.column :body_id,          :integer
      t.column :excerpt_id,       :integer
      t.column :created_on,       :datetime
      t.column :updated_on,       :datetime
      t.column :published_on,     :datetime
      t.column :published,        :boolean, :default => false
      t.column :comments_count,   :integer, :default => 0
    end

    add_index(:articles, :blog_id)
    add_index(:articles, :user_id)
  end

  ################################################################################
  def self.down
    drop_table :articles
    drop_table :blogs
  end

end
################################################################################
