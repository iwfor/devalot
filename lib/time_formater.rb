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
module TimeFormater
  ################################################################################
  include ActionView::Helpers::DateHelper
  extend  ActionView::Helpers::DateHelper

  ################################################################################
  ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.update(:smart => '')

  ################################################################################
  def format_time_from (time, user=nil, relative_to=Time.now)
    return '' if time.nil?

    if (relative_to - time) < 1.hour
      distance_of_time_in_words(time, relative_to, false) + ' ago'
    else
      format = user.time_format if user
      format = :smart unless !format.blank?
      format = :smart unless ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.has_key?(format.to_sym)

      zone = user.time_zone if user
      zone = 'London' if zone.blank? or TimeZone[zone].nil?
      TimeZone[zone].adjust(time).to_s(format.to_sym)
    end
  end

  ################################################################################
  def possible_time_formats (reference_point=Time.now)
    ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.keys.map(&:to_s).sort.map do |fmt|
      [fmt, reference_point.to_s(fmt.to_sym) + " (#{fmt.humanize})"]
    end
  end

  ################################################################################
  def self.smart_time_formatter (time)
    now = Time.now

    if time.year == now.year and time.mon == now.mon and time.day == now.day
      distance_of_time_in_words(time, now, false) + ' ago'
    elsif time.year == now.year
      time.strftime('%b %d')
    else
      time.strftime('%b %d, %Y')
    end
  end

end
################################################################################
class Time
  ################################################################################
  alias to_s_before_smart to_s

  def to_s (format=:default)
    return TimeFormater.smart_time_formatter(self) if format == :smart
    return to_s_before_smart(format)
  end

end
################################################################################
