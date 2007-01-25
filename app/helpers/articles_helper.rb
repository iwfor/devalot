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
module ArticlesHelper
  ################################################################################
  def articles_form (article, form)
    form.text_field(:title, 'Title:', :id => 'article_title')
    form.text_field(:slug,  'Slug: (for the URL)', :id => 'article_slug')

    if article.new_record?
      form.subform(EasyForms::Description.new {|f| f.text_field(:tags, "Initial Tags:")})
    end

    form.subform(filtered_text_form(article.body, 'Body'))
  end

  ################################################################################
  def articles_url (action=nil, article=nil)
    url = {:controller => 'articles'}

    url[:action] = action if action
    url[:id]     = article if article

    if article and article.blog
      url[:project] = article.blog.bloggable if Project === article.blog.bloggable

      if action == 'show' and article.published?
        url[:year]  = article.year
        url[:month] = article.month.to_s.rjust(2, '0')
        url[:day]   = article.day.to_s.rjust(2, '0')
        url[:id]    = article.slug
        url[:blog]  = article.blog.slug
      else
        url[:blog]  = article.blog.slug
      end

    else
      url[:project] = @project if @project
      url[:blog] = (@blog.blank? ? 'news' : @blog.slug)
    end

    url
  end

end
################################################################################
