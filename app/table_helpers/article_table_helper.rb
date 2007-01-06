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
class ArticleTableHelper < TableMaker::Proxy
  ################################################################################
  include ApplicationHelper
  include ArticlesHelper
  include PeopleHelper
  include TimeFormater

  ################################################################################
  columns(:only => [:title, :published, :user, :published_on, :created_on, :updated_on])

  ################################################################################
  def display_value_for_controls_column (article)
    generate_icon_form('app/pencil.jpg', :url => articles_url('edit').update(:id => article))
  end

  ################################################################################
  def display_value_for_title (article)
    link_to(h(truncate(article.title)), articles_url('show').update(:id => article))
  end

  ################################################################################
  def display_value_for_published (article)
    form_options = {
      :url  => articles_url('publish').update(:id => article),
      :html => {:class => 'plus_minus_button', :title => 'Toggle Published State'},
      :xhr  => true,
    }

    if article.published?
      generate_icon_form('app/minus.gif', form_options) + ' Yes'
    else
      generate_icon_form('app/plus.gif', form_options)  + ' No'
    end
  end

  ################################################################################
  def display_value_for_user (article)
    link_to_person(article.user)
  end

  ################################################################################
  [:published_on, :created_on, :updated_on].each do |m|
    class_eval <<-EOT
      def display_value_for_#{m} (a) 
        return "" if a.#{m}.nil?
        format_time_from(a.#{m}, @controller.current_user)
      end
    EOT
  end

end
################################################################################
