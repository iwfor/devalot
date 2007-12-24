################################################################################
#
# Copyright (C) 2006-2007 pmade inc. (Peter Jones pjones@pmade.com)
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
# 
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
################################################################################
class Ticket < ActiveRecord::Base
  ################################################################################
  # How many characters to take from the summary to make the title
  INITIAL_TITLE_LENGTH = 32

  ################################################################################
  # Ticket states - ALSO SEE state_title_from_name !
  STATES = [
    {:name => :new,       :value => 10, :state => :open},
    {:name => :open,      :value => 20, :state => :open},
    {:name => :reopen,    :value => 30, :state => :open},
    {:name => :resolved,  :value => 40, :state => :closed},
    {:name => :invalid,   :value => 50, :state => :closed},
    {:name => :duplicate, :value => 60, :state => :closed},
  ]

  OPEN_STATES   = STATES.select {|s| s[:state] == :open  }.map {|s| s[:value]}
  CLOSED_STATES = STATES.select {|s| s[:state] == :closed}.map {|s| s[:value]}

  ################################################################################
  acts_as_ferret :fields => {
    :project => {},
    :title => { :boost => 1.3 },
    :summary_body => { :boost => 1.0 },
    :tags => { :boost => 1.2 },
    :priority => {},
    :severity => {}
  }, :store_class_name => true

  ################################################################################
  # Each ticket can have any number of tags
  acts_as_taggable

  ################################################################################
  # validations
  validates_presence_of(:title)
  
  ################################################################################
  belongs_to(:project)
  belongs_to(:severity)
  belongs_to(:priority)

  ################################################################################
  # This ticket may be marked as a duplicate of another ticket
  belongs_to(:duplicate_of, :class_name => 'Ticket', :foreign_key => 'duplicate_of_id')
  has_many(:duplicates,     :class_name => 'Ticket', :foreign_key => 'duplicate_of_id')

  ################################################################################
  # This ticket may be in a hierarchy
  belongs_to(:parent, :class_name => 'Ticket', :foreign_key => 'parent_id')
  has_many(:children, :class_name => 'Ticket', :foreign_key => 'parent_id')

  ################################################################################
  # A ticket has an id that points to the user that created the ticket
  belongs_to(:creator, :class_name => 'User', :foreign_key => 'creator_id')

  ################################################################################
  # A ticket can be assigned to one user at a time
  belongs_to(:assigned_to, :class_name => 'User', :foreign_key => 'assigned_to_id')

  ################################################################################
  # There is one wiki page that is the summary of this ticket
  has_filtered_text(:summary)

  ################################################################################
  # Each ticket keeps a history of its changes
  has_many(:histories, :class_name => 'TicketHistory', :foreign_key => 'ticket_id', :dependent => :destroy)

  ################################################################################
  # Each ticket has a list of users that caused changes (via histories) 
  # FIXME there is a bug in ActiveRecord where :uniq isn't applied when you do
  # collection.count
  has_many(:change_users, :through => :histories, :uniq => :true, :source => :user)

  ################################################################################
  # Comments
  has_many(:comments, :as => :commentable, :dependent => :destroy)

  ################################################################################
  # File attachments
  has_many(:attachments, :as => :attachable, :dependent => :destroy)

  ################################################################################
  # Create a TicketHistory
  before_save(:create_change_history)

  ################################################################################
  # Get the state value for the given name
  def self.state_value (name)
    v = STATES.find {|s| s[:name] == name}
    v.nil? ? nil : v[:value]
  end

  ################################################################################
  # Provide the text version of the state from the provided name.
  # This cannot be use constants for titles for gettext to work as expected.
  def self.state_title_from_name( name )
    titles = {  :new => _('New'),
                :open => _('Open'),
                :reopen => _('Resurrected'),
                :resolved => _('Resolved'),
                :invalid => _('Invalid'),
                :duplicate => _('Duplicate')
             }
    titles[name]
  end

  ################################################################################
  # Create a new ticket and save it to the db
  def initialize (attributes=nil, summary_attributes=nil, user=nil)
    super(attributes)
    return unless attributes
    raise "missing summary and user" unless summary_attributes and user

    if self.title.blank?
      # FIXME need to convert summary body to text first
      summary_body = summary_attributes[:body] || ''
      first_line = summary_body.split(/\r?\n/).first || ''
      self.title = first_line[0, INITIAL_TITLE_LENGTH]
      self.title << '...' if first_line.length > INITIAL_TITLE_LENGTH
    end

    self.priority = Priority.top_item if ! self.priority
    self.severity = Severity.top_item if ! self.severity
    self.update_summary(summary_attributes, user)
    self.visible = user.has_visible_content?
    self.change_user = user

    # set the ticket state
    change_state(!self.assigned_to ? :new : :open)
  end

  ################################################################################
  # Set the user who is driving the change for this ticket
  def change_user= (user)
    @change_user_id = user.id
    self.creator = user if ! self.creator
  end

  ################################################################################
  # Get the title for the state of the ticket
  def state_title (state=nil)
    Ticket.state_title_from_name( state_name(state) )
  end

  ################################################################################
  # Get the name for the state of the ticket
  def state_name (state=nil)
    state = self.state if state.nil?
    STATES.find {|s| s[:value] == state}[:name]
  end

  ################################################################################
  # Has the ticket been changed at all?
  def has_been_updated?
    self.histories.count > 1
  end

  ################################################################################
  # Is this ticket in an open state?
  def open?
    OPEN_STATES.include?(self.state)
  end

  ################################################################################
  # Can the given user edit the ticket summary?
  def can_edit_summary? (user)
    return true if user.projects.include?(self.project)

    if user == self.summary.updated_by and 
      (Time.now - self.summary.created_on) <= 30.minutes
    then
      return true
    end

    return false
  end

  ################################################################################
  # Mark this ticket as being a duplicate ticket of the given other ticket.
  def mark_duplicate_of (other_ticket_id)
    return nil if self.id == other_ticket_id
    other_ticket = Ticket.find_by_id(other_ticket_id)
    return nil if other_ticket.nil?

    self.duplicate_of = other_ticket
    change_state(:duplicate)
    true
  end
  
  ################################################################################
  # Change the state of this ticket
  def change_state (state_name)
    value = self.class.state_value(state_name)
    raise "bad state name #{state_name}" if value.nil?
    self.state = value
  end

  ################################################################################
  # Called by the commentable code to notify that a comment was added
  def comment_added (comment)
    # if comment.visible?
    # 
    # Always store a coment in the history, even if the user has no visibilty
    # rights, this way at least we receive notification that something has 
    # changed. Otherwise comments could go unnoticed for a long time.
    # 
    # TODO it would also be a good idea to register deleted comments.
    # 
    history = self.histories.build
    history.add_comment(comment)
    history.save
    
    update_timestamp_without_history
  end

  ################################################################################
  # Called when a tag has been added
  def tagging_added (tagging)
    tagging.project_id = self.project_id
    update_timestamp_without_history
  end

  ################################################################################
  # Called to notify that a ticket was added
  def file_attached (attachment)
    history = self.histories.build
    history.description = [ { :change => "attachment", 
      :name => File.basename(attachment.filename) } ]
    history.user = attachment.user
    history.save

    update_timestamp_without_history
  end

  ################################################################################
  private

  ################################################################################
  # A simple way to update our updated_on attribute without calling
  # create_change_history
  def update_timestamp_without_history
    self.class.update_all(self.class.send(:sanitize_sql, ['updated_on = ?', Time.now]),
                          self.class.send(:sanitize_sql, ['id = ?', self.id])
                         )
  end

  ################################################################################
  # Hook into the ActiveRecord save process and create a change history
  def create_change_history
    change_descriptions = []

    if self.new_record?
      change_descriptions << { :change => :new, :title => self.title }
    else
      # something happened to the ticket, so change state from new to open
      change_state(:open) if self.state == STATES.first[:value]

      old_self = self.class.find(self.id)
      self_attrs = self.attributes
      old_self_attrs = old_self.attributes

      attributes_to_skip = self.class.reflect_on_all_associations.map {|a| a.primary_key_name}
      attributes_to_skip << 'created_on'
      attributes_to_skip << 'updated_on'

      (self_attrs.keys - attributes_to_skip).each do |attribute|
        if self_attrs[attribute] != old_self_attrs[attribute]
          old_value = old_self_attrs[attribute].to_s
          new_value = self_attrs[attribute].to_s

          if attribute == 'state'
            #old_value = state_title(old_self_attrs[attribute])
            #new_value = state_title(self_attrs[attribute])
            old_value = state_name(old_self_attrs[attribute])
            new_value = state_name(self_attrs[attribute])
          end

          old_value = '' if old_value.nil?
          # desc = "#{attribute.to_s.humanize} changed from #{old_value} to #{new_value}"
          change_descriptions << {:attribute => attribute.to_s, :change => 'edit',
                  :from => old_value, :to => new_value }
        end
      end

      self.class.reflect_on_all_associations.each do |assoc|
        next unless [:belongs_to, :has_one].include?(assoc.macro)

        if self.send(assoc.name) != old_self.send(assoc.name)
          desc = { :attribute => assoc.name.to_s }
          old_value = nil
          new_value = nil

          [:title, :name].each do |m|
            if self.send(assoc.name).respond_to?(m) or old_self.send(assoc.name).respond_to?(m)
              old_value = old_self.send(assoc.name).send(m) unless old_self.send(assoc.name).nil?
              new_value = self.send(assoc.name).send(m) unless self.send(assoc.name).nil?
              break
            end
          end

          if old_value and new_value
            desc.update( :change => "edit", :from => old_value, :to => new_value )
          elsif new_value
            desc.update( :change => "set", :to => new_value )
          elsif old_value
            desc.update( :change => "unset", :from => old_value )
          else
            desc.update( :change => "edit" )
          end

          change_descriptions << desc
        end
      end
    end

    # check to see if the summary changed
    if self.summary.changed?
      change_descriptions << { :attribute => "summary", :change => "edit" }
    end

    unless change_descriptions.empty?
      raise "change_user= was not called for this change" unless @change_user_id
      self.histories.build(:user_id => @change_user_id, :description => change_descriptions)
    end
  end
 
end
################################################################################
