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
require 'rtf'
################################################################################
class RTF::CommandNode
  def link (href, style=nil)
    text = StringIO.new
    text << '\field{\\*\\fldinst'
    text << "{HYPERLINK \"#{href}\"}}{\\fldrslt "

    if style.nil?
      style = RTF::CharacterStyle.new
      style.underline = true
      style.foreground = RTF::Colour.new(0, 0, 255)
    end

    root.colours << style.foreground if style.foreground != nil
    root.colours << style.background if style.background != nil
    root.fonts << style.font if style.font != nil
    text << style.prefix(root.fonts, root.colours) if style != nil

    node = RTF::CommandNode.new(self, text.string, '}')
    yield node if block_given?
    self.store(node)
  end
end
################################################################################
class TableMaker::Proxy < ActionView::Base
  attr_accessor :current_rtf_node

  ################################################################################
  def rtf_link_reset
    self.class.instance_eval { define_method(:link_to) {|args| rtf_link_to(*args)} }
    yield
    self.class.instance_eval { remove_method(:link_to) }
  end

  ################################################################################
  def rtf_link_to (title, url={}, other=nil)
    url = url_for(url.merge(:only_path => false)) if url.is_a?(Hash)
    @current_rtf_node.link(url) {|l| l << title}
    ''
  end

end
################################################################################
