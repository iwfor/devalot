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
module PagesHelper
  ################################################################################
  def url_for_page (page)
    {:controller => 'pages', :action => 'show', :id => page, :project => page.project, :only_path => false}
  end

  ################################################################################
  def link_to_page_object (page)
    title = page.title
    title = page.project.name if title == 'index'
    link_to(h(title), url_for_page(page))
  end

  ################################################################################
  def link_to_page (title)
    return title unless @project
    page_id = title

    title.sub!(/^([^:]+):(.+)$/) do |match|
      page_id = $2
      $1
    end

    page = @project.pages.find_by_title(page_id)

    if page
      link_to(title, url_for_page(page))
    elsif current_user.can_create_pages?(@project)
      link_to(title, {
        :controller => 'pages',
        :action     => 'new',
        :id         => page_id,
        :project    => @project,
      }, {:class => 'nonexistent'})
    else
      title
    end
  end
  
  ################################################################################
  def link_to_page_editor (page)
    link_with_pencil({
      :controller => 'pages',
      :action     => 'edit',
      :id         => page,
      :project    => page.project,
    })
  end

  ################################################################################
  def render_page (page)
    result = render_filtered_text(page.filtered_text)

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
  
end
################################################################################
