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
class Policy < ActiveRecord::Base
  ################################################################################
  validates_inclusion_of(:value_type, :in => %w(bool int str))
  validates_presence_of(:description)
  # FIXME WTF validates_presence_of(:value)
  validates_uniqueness_of(:name)

  ################################################################################
  # Locate the given policy, and run a test on it
  def self.check (name, test=nil)
    policy = self.find_by_name(name.to_s) or raise "invalid policy #{name}"

    case test
    when Proc
      test.call(policy.value)
    when nil
      policy.value == true
    else
      test == policy.value
    end
  end

  ################################################################################
  # Get the policy value
  def value 
    case self[:value_type]
    when 'bool'
      self[:value] == 'true'
    when 'int'
      self[:value].to_i
    else
      self[:value]
    end
  end

end
################################################################################
