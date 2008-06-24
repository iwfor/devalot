################################################################################
#
# Copyright (C) 2008 Isaac Foraker <isaac at noscience dot net>
# Copyright (C) 2006-2007 pmade inc. (Peter Jones <pjones at pmade dot com>)
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
# The HasHistory::ClassMethods module defines the has_history method to
# simplify adding history to a model with the correct mappings and its
# extensions.
module HasHistory
  module ClassMethods
    ############################################################################
    # The has_history method adds the has_many association to the History
    # model and sets up the appropriate relations and extensions.
    def has_history(attribute=:history)
      has_many attribute, :class_name => 'History', :as => :object, :extend => HistoryExtensions
    end
  end
end
