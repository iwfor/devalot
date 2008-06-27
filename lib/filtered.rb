################################################################################
#
# Copyright (C) 2008 Isaac Foraker <isaac at noscience dot net>
# Copyright (C) 2006-2007 pmade inc. (Peter Jones <pjones at pmade dot com>)
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
module Filtered
  class ProjectContext < Radius::Context
    ################################################################################
    def initialize (project, view)
      super()

      @project = project
      @view    = view
      globals.project = @project

      ################################################################################
      define_tag("project", :for => @project)

      ################################################################################
      define_tag("project:description") do |tag|
        @view.render_filtered_text(@project, :description)
      end

      ################################################################################
      define_tag("page") do |tag|
        tag.locals.page = @project.pages.find_by_title(tag.attr['title'])
        tag.expand
      end

      ################################################################################
      define_tag("page:content") do |tag|
        #@view.render_filtered(tag.local.page)
        @view.render_filtered_text(tag.locals.page)
      end

      ################################################################################
      define_tag("tickets") do |tag|
        tag.expand
      end

      ################################################################################
      define_tag("tickets:link") do |tag|
        @view.link_to(tag.attr['title'] || "tickets", {
          :controller => 'tickets',
          :action     => 'new',
          :project    => @project,
        })
      end

      ################################################################################
      define_tag(APP_NAME.downcase) do |tag|
        title = tag.attr['title'] || APP_NAME
      %Q(<a href="#{APP_HOME}">#{title}</a>)
      end

      ################################################################################
      define_tag('code') do |tag|
        language = tag.attr['lang'] || 'ruby'
        code = tag.expand.split(/\r?\n/)
        code.shift if code.first.match(/^\s*$/)
        CodeRay.scan(code.join("\n"), language).div(:line_numbers => :table)
      end

    end

  end

  ##############################################################################
  def render_filtered(owner, record, field, user=nil)
#    filter_cache = record.send "#{field}_cache" if record.respond_to?("#{field}_cache".to_sym)
#    return filter_cache if filter_cache
    body = record.send field
    filter = record.send "#{field}_filter"
    user||= User.new

    project = record.project if record.respond_to?(:project)
    allow_radius  = user.projects.include?(project) || user.can_use_radius?
    skip_sanitize = user.projects.include?(project) || user.can_skip_sanitize?

    # Replace the following items
    #
    # 1. Wiki links that are surrounded by [[ and ]]
    # 2. References to tickets like 'ticket 1' or 'ticket #1'
    # 3. Escape references like 'ticket \1' and 'ticket #\1'
    #
    # See PagesHelper::link_to_page for what goes between [[ and ]]
    filtered_body = ''
    unless body.blank?
      filtered_body = body.gsub(/(?:\[\[([^\]]+)\]\]|\b(ticket|bug)\s#?(\\)?(\d+))/i) do |match|
        if match[0,2] == '[['
          link_to_page($1, record)
        elsif $3 == '\\'
          match.sub('\\', '')
        else
          link_to_ticket(match, $4)
        end
      end
    end

    # Run the text through a filter like Textile
    filtered_body = TextFilter.filter_with(filter, filtered_body)

    if allow_radius
#      begin
        context = ProjectContext.new(@project, owner)
        parser = Radius::Parser.new(context, :tag_prefix => 'r')
        filtered_body = parser.parse(filtered_body)
#      rescue => e
#        filtered_body = "<pre>\nException rendering page:\n#{e.inspect}\n#{e.backtrace[0..9].join("\n")}</pre>"
#      end
    end

    # Replace text that looks like links with links, avoiding real links
    filtered_body.gsub!(/(?:=")?([a-z]+:\/\/(?:[\w\/:;=&\?\.\-\#\+\%]+))/) do |match|
      if match[0,2] == '="'
        match
      else
        dollar_1 = $1.dup
        url = dollar_1.sub(/[\.\?]$/, '')
        ending = dollar_1.sub(url, '')
            %Q(<a href="#{url}">#{url}</a>#{ending})
      end
    end

    unless skip_sanitize
      filtered_body = sanitize(filtered_body)
    end

#    record.send("#{field}_cache=", filtered_body)
#    record.save

    filtered_body
  end
end
