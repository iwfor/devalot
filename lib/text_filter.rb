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
class TextFilter
  ################################################################################
  def self.inherited (klass)
    instance_eval { (@filters ||= {}).store(klass.to_s.sub(/Filter/, ''), klass) }
  end

  ################################################################################
  def self.list
    ["None", instance_eval {@filters.keys}].flatten
  end

  ################################################################################
  def self.filter_with (filter_name, text)
    if filter_klass = instance_eval {@filters[filter_name]}
      filter_klass.filter(text)
    else
      text
    end
  end

end
################################################################################
Dir.foreach(File.join(File.dirname(__FILE__), 'text_filters')) do |file|
  require 'text_filters/' + file if file.match(/\.rb$/)
end
################################################################################