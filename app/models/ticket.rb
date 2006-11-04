################################################################################
#
# Copyright (C) 2006 Peter J Jones (pjones@pmade.com)
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
  # Ticket states
  STATES = [
    {:title => 'New',     :name => :new,      :value => 1},
    {:title => 'Open',    :name => :open,     :value => 2},
    {:title => 'Working', :name => :working,  :value => 3},
    {:title => 'Fixed',   :name => :fixed,    :value => 4},
    {:title => 'Closed',  :name => :closed,   :value => 5},
  ]

  ################################################################################
  # validations
  validates_presence_of(:title)
  
  ################################################################################
  belongs_to(:project)
  belongs_to(:severity)
  belongs_to(:priority)

  ################################################################################
  # This ticket may be marked as a duplicate of another ticket
  belongs_to(:duplicate_of, :class_name => 'Ticket', :foreign_key => 'duplicate_of')
  has_many(:duplicates,     :class_name => 'Ticket', :foreign_key => 'duplicate_of')

  ################################################################################
  # This ticket may be in a hierarchy
  belongs_to(:parent, :class_name => 'Ticket', :foreign_key => 'parent_id')
  has_many(:children, :class_name => 'Ticket', :foreign_key => 'parent_id')

  ################################################################################
  # A ticket has an id that points to the user that created the ticket
  belongs_to(:creator, :class_name => 'User', :foreign_key => 'creator_id')

  ################################################################################
  # A ticket can be assigned to one user at a time
  belongs_to(:assigned_to, :class_name => 'User', :foreign_key => 'assigned_to')

  ################################################################################
  # There is one wiki page that is the summary of this ticket
  belongs_to(:summary, :class_name => 'Page', :foreign_key => 'summary_id')

  ################################################################################
  # Each ticket keeps a history of its changes
  has_many(:histories, :class_name => 'TicketHistory', :foreign_key => 'ticket_id')

  ################################################################################
  # Create a TicketHistory
  before_save(:create_change_history)

  ################################################################################
  # Get the state value for the given name
  def self.state_value (name)
    STATES.find {|s| s[:name] == name}[:value]
  end

  ################################################################################
  # Create a new ticket and save it to the db
  def self.create (attributes, project, user)
    summary = attributes.delete(:summary) or raise "missing summary"

    first_line = summary.split(/\r?\n/).first
    title = first_line[0, INITIAL_TITLE_LENGTH]
    title << '...' if first_line.length > INITIAL_TITLE_LENGTH

    ticket = project.tickets.build(attributes.merge(:title => title))
    ticket.priority = Priority.top_item unless ticket.has_priority?
    ticket.state = state_value(:new)
    ticket.change_user = user
    return ticket unless ticket.save

    ticket.create_summary(:project_id => ticket.project.id, :title => "Ticket #{ticket.id} Summary", :body => summary)
    ticket.save

    ticket
  end

  ################################################################################
  # Set the user who is driving the change for this ticket
  def change_user= (user)
    @change_user_id = user.id
    self.creator_id = user unless self.has_creator?
  end

  ################################################################################
  # Get the title for the state of the ticket
  def state_title
    STATES.find {|s| s[:value] == self.state}[:title]
  end

  ################################################################################
  # Has the ticket been changed at all?
  def has_been_updated?
    (self.updated_on - self.created_on) > 60
  end

  ################################################################################
  private

  ################################################################################
  # Hook into the ActiveRecord save process and create a change history
  def create_change_history
    change_descriptions = []

    if self.new_record?
      change_descriptions << "Ticket Created"
    else
      old_self = self.class.find(self.id)

      self_attrs = self.attributes
      old_self_attrs = old_self.attributes

      attributes_to_skip = self.class.reflect_on_all_associations.map {|a| a.primary_key_name}
      attributes_to_skip << 'created_on'
      attributes_to_skip << 'updated_on'

      (self_attrs.keys - attributes_to_skip).each do |attribute|
        if self_attrs[attribute] != old_self_attrs[attribute]
          change_descriptions << "#{attribute.to_s.camelize} changed from #{old_self_attrs[attribute]} to #{self_attrs[attribute]}"
        end
      end
    end

    unless change_descriptions.empty?
      raise "change_user_id= was not called for this change" unless @change_user_id
      self.histories.build(:user_id => @change_user, :description => change_descriptions)
    end
  end
end
################################################################################
