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
class ApplicationController < ActionController::Base
  ################################################################################
  # Pick a unique cookie name to distinguish our session data from others'
  session(:session_key => '_devalot_session_id')

  ################################################################################
  before_filter(:project_object)

  ################################################################################
  # Add our custom helper modules
  helper(:forms)

  ################################################################################
  # move this somewhere because here it causes problems due to rails changeset
  # 5454.  The change set unloads the AuthHelper but since it depends on User,
  # it's not fully unloaded and then blows up when it gets loaded next time.
  require 'app/helpers/auth_helper.rb'
  add_template_helper(AuthHelper)

  ################################################################################
  # And some helpers we want to use throughout the app
  helper(:filtered_text)
  helper(:pages)
  helper(:tickets)

  ################################################################################
  protected

  ################################################################################
  # make the AuthHelper calls available to controllers
  include AuthHelper
  include RenderHelper

  ################################################################################
  def self.without_project
    instance_eval { @without_project = true }
  end

  ################################################################################
  def self.require_authentication (options={})
    before_filter(:authenticate, options)
  end

  ################################################################################
  def self.require_authorization (*permissions)
    options = permissions.last.is_a?(Hash) ? permissions.pop : {}
    before_filter(options) {|c| c.instance_eval {authorize(*permissions)}}
  end

  ################################################################################
  # Filter param keys
  def strip_invalid_keys (hash, *keys)
    hash ||= {}
    (hash.keys - keys.map(&:to_s)).each {|key| hash.delete(key)}
  end

  ################################################################################
  # only execute the block when the correct permissions are given, on top of
  # that, redirect if permissions aren't good
  def when_authorized (*permissions, &block)
    if authorize(*permissions)
      yield if block_given?
    else
      redirect_to(request.env["HTTP_REFERER"] ? :back : home_url)
    end
  end

  ################################################################################
  def project_object
    return true if self.class.instance_eval { @without_project }

    # FIXME just log and redirect
    raise "missing project slug" unless params[:project]
    @project = Project.find_by_slug(params[:project])
    raise "Project.find failed" unless @project
    true
  end

end
################################################################################
