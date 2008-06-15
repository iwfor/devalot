################################################################################
#
# Copyright (C) 2008 Isaac Foraker <isaac@noscience.net>
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
module ApplicationHelper

#  def protect_against_forgery?
#    false
#  end

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
  # XXX See some repetition here?  Do something about it.
  def render_pencil_icon
    icon_tag(:pencil, :alt => 'edit')
  end

  ################################################################################
  def render_printer_icon
    icon_tag(:printer, :alt => 'print')
  end

  ################################################################################
  def render_pdf_icon
    icon_tag(:pdf, :alt => 'generate pdf')
  end

  ################################################################################
  def render_eye_icon
    icon_tag(:eye, :alt => 'watch', :id => 'watcher_image')
  end

  ################################################################################
  def render_no_eye_icon
    icon_tag(:no_eye, :alt => 'stop watching', :id => 'watcher_image')
  end


  ################################################################################
  def render_plus_minus (plus_minus_flag)
    plus_minus_flag ? icon_tag(:plus, :alt => 'add') : icon_tag(:minus, :alt => 'remove')
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
  def link_with_printer (options={})
    use_xhr = options.delete(:xhr)
    html_options = {:class => 'icon_link'}

    if use_xhr
      xhr_link(render_printer_icon, {:url => options}, html_options)
    else
      link_to(render_printer_icon, options, html_options)
    end
  end

  ################################################################################
  def link_with_pdf (options={})
    use_xhr = options.delete(:xhr)
    html_options = {:class => 'icon_link'}

    if use_xhr
      xhr_link(render_pdf_icon, {:url => options}, html_options)
    else
      link_to(render_pdf_icon, options, html_options)
    end
  end

  ################################################################################
  def xhr_link (title, options={}, html_options={})
    link_to_remote(title, options, html_options)
  end

  ################################################################################
  def help_link
    link_to(_('Help'), :project => 'support', :controller => 'pages', :action => 'show', :id => 'index')
  end

  ################################################################################
  def load_system_stickies
    report_stickie_collection(Stickie.find_for_user(current_user))
  end
  
  ################################################################################
  def report_stickie_collection (stickies)
    Stickies::Messages.fetch(session) do |messages|
      stickies.each do |stickie|
        unless messages.seen?(stickie.id, :since => stickie.updated_on)
          messages.add(stickie.message_type.downcase.to_sym, 
                       render_filtered_text(stickie),
                       :remember => true, :name => stickie.id)
        end
      end
    end
  end

  ################################################################################
  def url_for_tag_in_tag_cloud (tag)
    url = {:controller => 'tags', :action => 'show', :id => tag.name}
    url[:project] = @project if @project
    url
  end

  ################################################################################
  # Set options for all forms on this site
  def easy_forms_options (options)
    options[:spinner] = 'app/spinner.gif'
  end

end
################################################################################
