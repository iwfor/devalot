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
  protected
  
  ################################################################################
  # Add our custom helper modules
  helper(:forms)
  helper(:auth); include AuthHelper

  ################################################################################
  # And some helpers we want to use throughout the app
  helper(:pages)
  helper(:tickets)

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
    before_filter(options) {|c| c.authorize(*permissions)}
  end

  ################################################################################
  # Filter param keys
  def strip_invalid_keys (hash, *keys)
    hash ||= {}
    (hash.keys - keys.map(&:to_s)).each {|key| hash.delete(key)}
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
