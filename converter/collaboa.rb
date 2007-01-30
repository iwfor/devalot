#!/usr/bin/env ruby
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
require File.dirname(__FILE__) + '/../config/environment'
require 'highline/import'
################################################################################
STATE_MAP = {
  'Open'       => Ticket::STATES.find {|s| s[:name] == :open}[:value],
  'Fixed'      => Ticket::STATES.find {|s| s[:name] == :resolved}[:value],
  'Duplicate'  => Ticket::STATES.find {|s| s[:name] == :duplicate}[:value],
  'Invalid'    => Ticket::STATES.find {|s| s[:name] == :invalid}[:value],
  'WorksForMe' => Ticket::STATES.find {|s| s[:name] == :invalid}[:value],
  'WontFix'    => Ticket::STATES.find {|s| s[:name] == :invalid}[:value],
}

SEVERITY_MAP = {
  'Enhancement'=> 'Enhancement Request', 
  'Normal'     => 'Assistance Request', 
  'Minor'      => 'Minor Problem', 
  'Major'      => 'Major Problem', 
  'Critical'   => 'Critical Problem',
  'Blocker'    => 'Critical Problem',
}
################################################################################
class ConvertCollaboa < ActiveRecord::Base
  def self.abstract_class?; true; end
  establish_connection(:collaboa)

  ################################################################################
  class Project < ConvertCollaboa
    has_many(:tickets)
  end

  ################################################################################
  class Ticket < ConvertCollaboa
    belongs_to(:status)
    belongs_to(:severity)
    has_many(:ticket_changes, :order => 'created_at desc')
  end

  ################################################################################
  class TicketChange < ConvertCollaboa
    serialize(:log)
  end

  ################################################################################
  class Status < ConvertCollaboa
    set_table_name('status')
  end

  ################################################################################
  class Severity < ConvertCollaboa
  end

end

################################################################################
def select_devalot_project
  choose do |menu|
    menu.prompt = "Select the Devalot project to import into: "
    Project.find(:all).each {|p| menu.choice(p.name) {return p}}
  end
end

################################################################################
def select_collaboa_project
  choose do |menu|
    menu.prompt = "Select the Collaboa project to import from: "
    ConvertCollaboa::Project.find(:all).each {|p| menu.choice(p.name) {return p}}
  end
end

################################################################################
def map_user (collaboa_user)
  User.find(1)
end

################################################################################
devalot_project  = select_devalot_project
collaboa_project = select_collaboa_project

collaboa_project.tickets.find(:all, :order => :id).each do |c_ticket|
  puts c_ticket.summary

  d_ticket = devalot_project.tickets.build({:title => c_ticket.summary}, {
    :body => c_ticket.content, :filter => 'Textile'
  }, map_user(c_ticket.author))

  d_ticket.state = STATE_MAP[c_ticket.status.name]
  d_ticket.severity = Severity.find_by_title(SEVERITY_MAP[c_ticket.severity.name])
  d_ticket.created_on = c_ticket.created_at

  if c_ticket.has_ticket_changes?
    d_ticket.updated_on = c_ticket.ticket_changes.find(:first).created_at
  end

  d_ticket.save!
  d_ticket.histories.destroy_all

  c_ticket.ticket_changes.each do |change|
    if !change.comment.blank? and !change.comment.match(/^\s*Created\s*$/)
      comment = d_ticket.comments.build(:user => map_user(change.author))
      comment.build_filtered_text(:body => change.comment, :filter => 'Textile')
      comment.created_on = change.created_at
      comment.updated_on = change.created_at
      comment.save!
    end

    change.log = [change.comment] if change.log.blank?

    d_ticket.histories.create({
      :user => map_user(change.author), 
      :created_on => change.created_at,
      :description => Array(change.log),
    })
  end
end
################################################################################
