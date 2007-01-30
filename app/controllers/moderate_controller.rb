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
# TODO I had a ton of problems with an around filter here
class ModerateController < ApplicationController
  ################################################################################
  require_authorization(:can_moderate)

  ################################################################################
  without_project

  ################################################################################
  def index
    list
    render(:action => 'list')
  end

  ################################################################################
  def list
    @layout_feed = {:action => 'moderate', :code => Policy.lookup(:moderation_feed_code).value}
    @conditions = User.calculate_find_conditions_for_moderated_users
  end

  ################################################################################
  def destroy
    user_check { @user.lock_and_destroy(current_user) }
  end

  ################################################################################
  def promote
    user_check { @user.promote_and_make_visible(current_user) }
  end

  
  ################################################################################
  private

  ################################################################################
  def user_check
    @user = User.find(params[:id])

    if @user.points == 0
      current_user.points += 1 if yield
      current_user.save
    end

    @user.save

    redirect_to(params[:url] || home_url)
  end

  ################################################################################

end
################################################################################
