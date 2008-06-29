################################################################################
class ConvertProjectDescription < ActiveRecord::Migration
  ##############################################################################
  # To avoid relation and validation conflicts, declare the models for the
  # tables that will be read or modified.
  class FilteredText < ActiveRecord::Base
  end

  class FilteredTextVersion < ActiveRecord::Base
  end

  class Project < ActiveRecord::Base
    has_many :history, :class_name => 'History', :as => :object
  end

  ##############################################################################
  def self.up
    # Add columns to projects table
    add_column :projects, :description, :text
    add_column :projects, :description_filter, :string
    add_column :projects, :nav_content, :text
    add_column :projects, :nav_content_filter, :string
    add_column :projects, :updated_on, :datetime

    # Import filtered_text contents into projects table
    Project.find(:all).each do |project|
      desc = FilteredText.find project.description_id
      nav = FilteredText.find project.nav_content_id
      unless desc.blank?
        project.description = desc.body
        project.description_filter = desc.filter
      end
      unless nav.blank?
        project.nav_content = nav.body
        project.nav_content_filter = nav.filter
      end
      project.save!

      # Create a history for each project
      unless desc.blank?
        first = true
        FilteredTextVersion.find(:all, :conditions => "filtered_text_id in (#{desc.id},#{nav.id})", :order => :id).each do |r|
          # Create a history entry
          history = project.history.build(
            :project_id => project.id,
            :user_id => r.updated_by_id,
            :action => (first ? "Created '#{project.name}'" : "Edited '#{project.name}'"),
            :created_at => r.created_on
          )
          history.history_entries.build(
            :action     => (first ? 'create' : 'edit'),
            :field      => 'description',
            :value      => r.body,
            :value_type => 'String'
          )
          if first
            history.history_entries.build(
              :action     => 'create',
              :field      => 'name',
              :value      => project.name,
              :value_type => 'String'
            )
          end
          history.save
          first = false
        end
      end
    end
  end

  ##############################################################################
  def self.down
    remove_column :projects, :description
    remove_column :projects, :description_filter
    remove_column :projects, :nav_content
    remove_column :projects, :nav_content_filter
    remove_column :projects, :updated_on
  end
end
