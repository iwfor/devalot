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
# Register to get notified when policies change
class PolicyCallback
  ################################################################################
  @@callbacks = {}

  ################################################################################
  def self.register (policy_name, klass, method_to_use=:callback)
    fetch_callbacks_for(policy_name) << [klass, method_to_use]
  end

  ################################################################################
  def self.call_for (policy)
    fetch_callbacks_for(policy.name).each {|p| p.first.send(p.last, policy)}
  end

  ################################################################################
  def self.fetch_callbacks_for (policy_name)
    @@callbacks[policy_name.to_sym] ||= []
    @@callbacks[policy_name.to_sym]
  end

end
################################################################################
Dir.foreach(File.join(File.dirname(__FILE__), 'policy_callbacks')) do |file|
  require 'policy_callbacks/' + file if file.match(/\.rb$/)
end
################################################################################
