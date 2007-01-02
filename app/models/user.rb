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
class User < ActiveRecord::Base
  ################################################################################
  attr_protected(:is_root)

  ################################################################################
  validates_presence_of(:first_name, :last_name, :email)

  ################################################################################
  validates_uniqueness_of(:email)

  ################################################################################
  has_many(:positions, :include => [:project, :role], :order => 'projects.name')
  has_many(:projects, :through => :positions)
  
  ################################################################################
  has_many(:assigned_tickets, :class_name => 'Ticket', :foreign_key => 'assigned_to_id')

  ################################################################################
  # add a bunch of helper methods for figuring out permissions
  Role.column_names.each do |name|
    next unless name.match(/^can_/)

    class_eval <<-END
      def #{name}? (project)
        return true if self.is_root?
        return false unless position = self.positions.find_by_project_id(project.id)
        position.role.#{name} == true
      end
    END
  end

  ################################################################################
  def self.from_account (account)
    user = User.find_by_account_id(account.id) || User.new(:account_id => account.id)

    # copy remote account attributes to the user object
    [:first_name, :last_name, :email].each {|a| user.send("#{a}=", account.send(a))}

    user.save
    user
  end

  ################################################################################
  def name
    "#{self.first_name} #{self.last_name}"
  end

end
################################################################################
