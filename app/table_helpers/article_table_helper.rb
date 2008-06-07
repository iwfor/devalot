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
class ArticleTableHelper < TableMaker::Helper
  ################################################################################
  include ArticlesHelper
  include PeopleHelper
  include TimeFormater

  ################################################################################
  columns(:only => [:title, :published, :user, :comments_count, :published_on, :created_on, :updated_on])
  columns(:hide => [:created_on])

  ################################################################################
  sort(:published_on, 
       :desc => 'published_on is null, published_on DESC, created_on DESC',
       :asc  => 'published_on is not null, published_on ASC, created_on ASC')

  sort(:user, :include => :user, 
       :asc  => 'users.first_name ASC, users.last_name ASC',
       :desc =>' users.first_name DESC, users.last_name DESC')


  ################################################################################
  def display_value_for_controls_column (article)
    generate_icon_form(icon_src(:pencil), :url => articles_url('edit', article))
  end

  ################################################################################
  def display_value_for_title (article)
    link_to(h(truncate(article.title)), articles_url('show', article))
  end

  ################################################################################
  def display_value_for_published (article)
    form_options = {
      :url  => articles_url('publish', article),
      :html => {:class => 'icon_form', :title => 'Toggle Published State'},
      :xhr  => true,
    }

    if article.published?
      generate_icon_form(icon_src(:minus), form_options) + ' Yes'
    else
      generate_icon_form(icon_src(:plus), form_options)  + ' No'
    end
  end

  ################################################################################
  def heading_for_user
    'Author'
  end

  ################################################################################
  def display_value_for_user (article)
    link_to_person(article.user)
  end

  ################################################################################
  def heading_for_comments_count
    "Comments"
  end

  ################################################################################
  [:published_on, :created_on, :updated_on].each do |m|
    class_eval <<-EOT
      def display_value_for_#{m} (a) 
        return "" if a.#{m}.nil?
        h(format_time_from(a.#{m}, @controller.current_user))
      end
    EOT
  end

end
################################################################################
