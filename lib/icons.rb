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
module Icons
  ################################################################################
  ICON_ATTRS = {
    :minus  => {:src => 'app/minus.gif',  :size => '14x14', :class => 'plus_minus_button'},
    :plus   => {:src => 'app/plus.gif',   :size => '14x14', :class => 'plus_minus_button'},
    :pencil => {:src => 'app/pencil.jpg', :size => '18x18', :class => 'icon_link'},
  }

  ################################################################################
  module ExtensionMethods
    ################################################################################
    def icon_tag (icon)
      attributes = Icons::ICON_ATTRS[icon]
      image_tag(attributes[:src], :size => attributes[:size], :class => attributes[:class])
    end

    ################################################################################
    def icon_src (icon)
      Icons::ICON_ATTRS[icon][:src]
    end

    ################################################################################
    def icon_class (icon)
      Icons::ICON_ATTRS[icon][:class]
    end

  end

  ################################################################################
  ActionController::Base.send(:include, Icons::ExtensionMethods)
  ActionView::Base.send(:include, Icons::ExtensionMethods)
end
################################################################################
