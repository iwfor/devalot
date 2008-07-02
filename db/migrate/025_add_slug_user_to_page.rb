################################################################################
class AddSlugUserToPage < ActiveRecord::Migration
  ##############################################################################
  # To avoid relation and validation conflicts, declare the models for the
  # tables that will be read or modified.
  class FilteredText < ActiveRecord::Base
  end

  class FilteredTextVersion < ActiveRecord::Base
  end

  class History < ActiveRecord::Base
    has_many :history_entries, :dependent => :delete_all
  end

  class Page < ActiveRecord::Base
    has_many :history, :class_name => 'History', :as => :record
  end

  class TimelineEntry < ActiveRecord::Base
  end


  ##############################################################################
  # Now alter the table and perform the conversion
  def self.up
    add_column :pages, :slug, :string
    add_column :pages, :body, :text
    add_column :pages, :body_cache, :text
    add_column :pages, :body_filter, :string
    add_column :pages, :created_by_id, :integer
    add_column :pages, :updated_by_id, :integer
    add_column :pages, :created_at, :datetime
    add_column :pages, :updated_at, :datetime

    ActiveRecord::Base.record_timestamps = false

    record_timestamps = ActiveRecord::Base.record_timestamps
    # Update each page record for the new structure
    Page.find(:all).each do |page|
      # Create a slug.
      # XXX Is there a better way to generate a slug?
      page.slug = page.title.gsub(/[\s\.,\?!@#\$%\^&\*\(\)-\+=]+/, '_').downcase
      # Import filtered_text
      ft = FilteredText.find page.filtered_text_id
      page.body = ft.body
      page.body_filter = ft.filter
      page.created_at = ft.created_on
      page.created_by_id = ft.created_by_id
      page.updated_at = ft.updated_on
      page.updated_by_id = ft.updated_by_id
      page.save!

      # Create a history for each page
      first = true
      FilteredTextVersion.find(:all, :conditions => { :filtered_text_id => ft.id }, :order => :id).each do |r|
        # Create a history entry
        history = page.history.build(
          :project_id => page.project_id,
          :user_id => r.updated_by_id,
          :action => (first ? "Created '#{page.title}'" : "Edited '#{page.title}'"),
          :created_at => ft.created_on
        )
        history.history_entries.build(
          :action     => (first ? 'create' : 'edit'),
          :field      => 'body',
          :value      => r.body,
          :value_type => 'String'
        )
        if first
          history.history_entries.build(
            :action     => 'create',
            :field      => 'title',
            :value      => page.title,
            :value_type => 'String'
          )
          history.history_entries.build(
            :action     => 'create',
            :field      => 'toc_element',
            :value      => page.toc_element,
            :value_type => 'String'
          )
          history.history_entries.build(
            :action     => 'create',
            :field      => 'body_filter',
            :value      => page.body_filter,
            :value_type => 'String'
          ) unless page.body_filter.blank?
        end
        history.save
        first = false
      end
    end

    ActiveRecord::Base.record_timestamps = record_timestamps
  end

  ##############################################################################
  def self.down
    History.find(:all, :conditions => { :object_type => 'Page' }).each do |r|
      r.destroy
    end
    remove_column :pages, :slug
    remove_column :pages, :body
    remove_column :pages, :body_cache
    remove_column :pages, :body_filter
    remove_column :pages, :created_by_id
    remove_column :pages, :updated_by_id
    remove_column :pages, :created_at
    remove_column :pages, :updated_at
  end
end
