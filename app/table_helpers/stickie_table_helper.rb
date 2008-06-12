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
class StickieTableHelper < TableMaker::Proxy
  ################################################################################
  include PeopleHelper
  include TimeFormater

  ################################################################################
  columns(:fake    => [:excerpt, :updated_by])
  columns(:only => [:id, :message_type, :stickiepad_type, :excerpt, :updated_by, :updated_on])

  ################################################################################
  def display_value_for_controls_column (stickie)
    result = generate_icon_form(icon_src(:pencil), :url => {:action => 'edit', :id => stickie})
    result << " "

    result << generate_icon_form(icon_src(:cross), {
      :url => {:action => 'destroy', :id => stickie},
      :confirm => 'Are you sure you want to delete this stickie?',
    })

    result
  end

  ################################################################################
  def heading_for_stickiepad_type
    "Context"
  end

  ################################################################################
  def display_value_for_stickiepad_type (stickie)
    stickie.stickiepad_type.blank? ? 'System' : stickie.stickiepad_type
  end

  ################################################################################
  def display_value_for_message_type (stickie)
    %Q(<div class="#{stickie.message_type.downcase}_stickie">#{stickie.message_type}</div>)
  end
  ################################################################################
  def display_value_for_excerpt (stickie)
    h(truncate(stickie.filtered_text.body, 40))
  end

  ################################################################################
  def display_value_for_updated_by (stickie)
    link_to_person(stickie.filtered_text.updated_by)
  end

  ################################################################################
  def display_value_for_updated_on (stickie)
    format_time_from(stickie.updated_on, @controller.current_user)
  end

end
################################################################################
