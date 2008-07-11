################################################################################
class CreateFilteredTexts < ActiveRecord::Migration
  ##############################################################################
  class User < ActiveRecord::Base
  end

  ##############################################################################
  def self.up
    create_table :filtered_texts do |t|
      t.text     :body
      t.text     :body_cache
      t.string   :filter
      t.datetime :created_on
      t.datetime :updated_on
      t.integer  :created_by_id
      t.integer  :updated_by_id
      t.integer  :version
      t.integer  :lock_version,   :default => 0
      t.boolean  :allow_caching,  :default => false
    end

    FilteredText.create_versioned_table

    ############################################################################
    admin_user = User.find(1)
    admin_user.description_id = FilteredText.create(
      :body => DefaultPages.fetch('users', 'admin_desc.html'), :filter => 'Textile'
    ).id
    admin_user.save!
  end

  ##############################################################################
  def self.down
    drop_table :filtered_texts
    FilteredText.drop_versioned_table
  end

end
################################################################################
