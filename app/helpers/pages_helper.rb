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
module PagesHelper
  ##############################################################################
  def url_for_page (page, action='show')
    {
      :controller => controller_for_page(page, action), 
      :action     => action, 
      :id         => page, 
      :project    => page.project, 
      :only_path  => false,
    }
  end

  ##############################################################################
  def link_to_page_object (page)
    title = page.title
    title = page.project.name if title == 'index' && page.project != nil
    link_to(h(title), url_for_page(page))
  end

  ##############################################################################
  # Given the title of a page, generate a link to it.  The +from+ argument is
  # used to figure out which project the page belongs to.  The format of the
  # title can be like so:
  #
  # * index - Link to the project index page
  # * Hello:index - Link to the project index page, but use "Hello" as the link title
  # * index#bar - Link to index, with anchor bar
  # * Hello:index#bar - Link to index, anchor bar, title "Hello"
  def link_to_page (title, from=nil)
    page_id = title.dup
    project = from.project if from.respond_to?(:project)

    # seperate out link title from page title
    title.sub!(/^([^:]+):(.+)$/) do |match|
      page_id = $2
      $1
    end

    # look for link anchors
    page_id.sub!(/#(.+)$/, '') and anchor = $1

    if project
      page = project.pages.find_by_title(page_id)
    else
      page = Page.system(page_id)
    end

    if page
      link_to(title, url_for_page(page).merge(:anchor => anchor))
    elsif (project and current_user.can_create_pages?(project)) or
      (!project and current_user.is_root?)
    then
      link_to(title, {
        :controller => controller_for_page(project, 'new'),
        :action     => 'new',
        :id         => page_id,
        :project    => project,
      }, {:class => 'nonexistent'})
    else
      title
    end
  end
  
  ##############################################################################
  def link_to_page_editor (page)
    link_with_pencil(url_for_page(page, 'edit'))
  end

  ##############################################################################
  def link_to_page_printer (page)
    link_with_printer(url_for_page(page, 'print'))
  end

  ##############################################################################
  def link_to_page_pdf (page)
    link_with_pdf(url_for_page(page, 'pdf'))
  end

  ##############################################################################
  def link_to_page_watcher (page)
    url = url_for_page(page, 'toggle_watch')
    watching = is_watching?
    icon = watching ? render_no_eye_icon : render_eye_icon
    link_to_remote(icon, :url => url)
  end

  ##############################################################################
  def is_watching?
    # XXX
  end

  ##############################################################################
  def toggle_page_watch
    watching = is_watching?
    icon = watching ? render_no_eye_icon : render_eye_icon
    # XXX
    icon
  end

  ##############################################################################
  def render_page (page)
    result = render_filtered_text(page)

    unless page.toc_element.blank?
      toc_counter = 0
      toc_titles = []

      result.gsub!(/<#{page.toc_element.downcase}[^>]*>([^<]+)/) do |match|
        with_link = %Q(<a name="toc_element_#{toc_counter}">#{match}</a>)

        toc_titles << $1
        toc_counter += 1

        with_link
      end

      toc = %Q(<div class="toc"><ul>)

      toc_titles.each_with_index do |t,i|
        toc << %Q(<li><a href="#toc_element_#{i}">#{t}</a></li>)
      end

      toc << %Q(</ul></div>)
      result = toc + result
    end

    result
  end
  
  ##############################################################################
  def controller_for_page (page, action)
    if page.respond_to?(:project) and page.project
      "/pages"
    elsif action == "show"
      "system/pages"
    else
      "admin/pages"
    end
  end

end
################################################################################
