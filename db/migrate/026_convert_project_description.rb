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
    has_many :history, :class_name => 'History'
  end

  class History < ActiveRecord::Base
    has_many :history_entries, :dependent => :delete_all
  end

  ##############################################################################
  def self.up
    # Add columns to projects table
    p = Project.new
    add_column :projects,  :description,         :text     unless p.respond_to?(:description)
    add_column :projects,  :description_filter,  :string   unless p.respond_to?(:description_filter)
    add_column :projects,  :nav_content,         :text     unless p.respond_to?(:nav_content)
    add_column :projects,  :nav_content_filter,  :string   unless p.respond_to?(:nav_content_filter)
    add_column :projects,  :updated_on,          :datetime unless p.respond_to?(:updated_on)

    if p.respond_to? :description_id
      record_timestamps = ActiveRecord::Base.record_timestamps
      ActiveRecord::Base.record_timestamps = false

      ActiveRecord::Base.transaction do
        # Import filtered_text contents into projects table
        Project.find(:all).each do |project|
          desc = project.description_id.blank? ? nil : FilteredText.find(project.description_id)
          nav = project.nav_content_id.blank? ? nil : FilteredText.find(project.nav_content_id)
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
              history = History.new(
                :project_id  => project.id,
                :object_id   => project.id,
                :object_type => 'Project',
                :user_id     => r.updated_by_id,
                :action      => (first ? "Created '#{project.name}'" : "Edited '#{project.name}'"),
                :created_at  => r.created_on
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
      ActiveRecord::Base.record_timestamps = record_timestamps
    end
  end

  ##############################################################################
  def self.down
    ActiveRecord::Base.transaction do
      History.find(:all, :conditions => { :object_type => 'Project' }).each do |r|
        r.destroy
      end
    end
  end
end
