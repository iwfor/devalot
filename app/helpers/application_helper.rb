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
module ApplicationHelper
  ################################################################################
  # wrap the body of the given block in a rounded line div
  def render_rounded_line (options={}, &block)
    configuration = {
      :separator => ' | ',
    }.update(options)

    items = []
    header = %Q(<div class="rounded_line"><div class="rounded_line_content"><p>)
    footer = %Q(</p></div></div><br class="clear"/>)
  
    if block.arity == 1
      yield(items)
      items.delete_if(&:blank?)
      return if items.blank?

      concat(header, block)
      concat(items.join(configuration[:separator]), block)
      concat(footer, block)
    else
      concat(header, block)
      yield
      concat(footer, block)
    end
  end

  ################################################################################
  def subnav (h1=nil, &block)
    if h1
      concat(%Q(<h1 id="subnav_title">#{h(h1)}</h1>), block)
    end

    concat(%Q(<div id="subnav">), block)
    render_rounded_line(&block)
    concat(%Q(</div><br class="clear"/>), block)
  end

  ################################################################################
  def render_tag_editor (object)
    if current_user.can_tag?
      tag_editor_for(object, {
        :add_button => render_plus_minus(true), 
        :remove_button => render_plus_minus(false),
      })
    end
  end

  ################################################################################
  def render_pencil_icon
    image_tag('app/pencil.jpg', :size => '18x18')
  end

  ################################################################################
  def render_plus_minus (plus_minus_flag)
    image_tag("app/#{plus_minus_flag ? 'plus' : 'minus'}.gif", :size => '14x14', :class => 'plus_minus_button')
  end

  ################################################################################
  def link_with_pencil (options={})
    use_xhr = options.delete(:xhr)
    html_options = {:class => 'icon_link'}

    if use_xhr
      xhr_link(render_pencil_icon, {:url => options}, html_options)
    else
      link_to(render_pencil_icon, options, html_options)
    end
  end

  ################################################################################
  def xhr_link (title, options={}, html_options={})
    link_to_remote(title, options, html_options)
  end

  ################################################################################
  def help_link
    link_to('Help', :project => 'support', :controller => 'pages', :action => 'show', :id => 'index')
  end

end
################################################################################
