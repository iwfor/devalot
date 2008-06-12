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
class PageTableHelper < TableMaker::Proxy
  ################################################################################
  include PagesHelper
  include PeopleHelper
  include TimeFormater

  ################################################################################
  columns(:include => [:title, :comments_count])
  columns(:fake    => [:created_by, :updated_by, :updated_on])
  columns(:order   => [:title, :comments_count, :created_by, :updated_by, :updated_on])

  ################################################################################
  sort(:created_by, :include => :filtered_text, 
       :joins => 'LEFT JOIN users ON filtered_texts.created_by_id = users.id',
       :asc  => 'users.first_name ASC, users.last_name ASC',
       :desc =>' users.first_name DESC, users.last_name DESC')

  sort(:updated_by, :include => :filtered_text, 
       :joins => 'LEFT JOIN users ON filtered_texts.updated_by_id = users.id',
       :asc  => 'users.first_name ASC, users.last_name ASC',
       :desc =>' users.first_name DESC, users.last_name DESC')

  sort(:updated_on, :include => :filtered_text, :asc => 'filtered_texts.updated_on')

  ################################################################################
  def display_value_for_controls_column (page)
    result = generate_icon_form(icon_src(:pencil), :url => {:action => 'edit', :id => page, :project => page.project})
    result << " "

    result << generate_icon_form(icon_src(:cross), {
      :url => {:action => 'destroy', :id => page, :project => page.project},
      :confirm => "Are your sure you want to delete the '#{page.title}' page?",
    })

    result
  end

  ################################################################################
  def display_value_for_title (page)
    title = page.title

    if title == "index"
      if page.project
        title = "#{h(page.project.name)} Main Page" 
      else
        title = "System Main Page (index)"
      end
    end

    link_to(h(truncate(title)), url_for_page(page))
  end

  ################################################################################
  def heading_for_comments_count
    "Comments"
  end

  ################################################################################
  def display_value_for_created_by (page)
    link_to_person(page.filtered_text.created_by)
  end

  ################################################################################
  def display_value_for_updated_by (page)
    link_to_person(page.filtered_text.updated_by)
  end

  ################################################################################
  def display_value_for_updated_on (page)
    h(format_time_from(page.filtered_text.updated_on, @controller.current_user))
  end

end
################################################################################
