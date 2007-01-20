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
class UserTableHelper < TableMaker::Proxy
  ################################################################################
  include ApplicationHelper
  include PeopleHelper
  include TimeFormater

  ################################################################################
  columns(:only => [:id, :enabled, :is_root, :first_name, :last_name, :email, :points, :created_on, :last_login])

  ################################################################################
  def display_value_for_controls_column (user)
    generate_icon_form('app/pencil.jpg', :url => {:action => 'edit', :id => user})
  end

  ################################################################################
  def display_value_for_enabled (user)
    form_options = {
      :url     => {:action => 'toggle_enabled', :id => user},
      :html    => {:class => 'plus_minus_button', :title => 'Toggle Enabled State'},
      :confirm => "#{user.enabled? ? 'Disable' : 'Enable'} the user account for #{user.name}?",
      :xhr     => true,
    }

    if user.enabled?
      generate_icon_form('app/minus.gif', form_options) + ' Yes'
    else
      generate_icon_form('app/plus.gif', form_options)  + ' No'
    end
  end
  ################################################################################
  def heading_for_is_root
    "Admin"
  end

  ################################################################################
  def display_value_for_is_root (user)
    user.is_root? ? "Yes" : "No"
  end

  ################################################################################
  def display_value_for_first_name (user)
    link_to_person(user, user.first_name)
  end

  ################################################################################
  def display_value_for_last_name (user)
    link_to_person(user, user.last_name)
  end

  ################################################################################
  [:created_on, :last_login].each do |m|
    class_eval <<-EOT
      def display_value_for_#{m} (a) 
        return "Never" if a.#{m}.nil?
        format_time_from(a.#{m}, @controller.current_user)
      end
    EOT
  end
end
################################################################################
