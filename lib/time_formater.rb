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

  ################################################################################
  def format_time_from (time, user, relative_to=Time.now)
    if (relative_to - time) < 1.hour
      distance_of_time_in_words(time, relative_to, false) + ' ago'
    else
      format = user.time_format
      format = :long unless !format.blank?
      format = :long unless ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.has_key?(format.to_sym)

      zone = user.time_zone
      zone = 'London' if zone.blank? or TimeZone[zone].nil?
      TimeZone[zone].adjust(time).to_s(format.to_sym)
    end
  end

  ################################################################################
  def possible_time_formats (reference_point=Time.now)
    ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.to_a.map do |fmt|
      [fmt.first, reference_point.strftime(fmt.last)]
    end
  end

end
################################################################################
