################################################################################
class ApplicationController < ActionController::Base
  ################################################################################
  # Pick a unique cookie name to distinguish our session data from others'
  session :session_key => '_devalot_session_id'

  ################################################################################
  before_filter(:project_object)

  ################################################################################
  private

  ################################################################################
  def project_object
    raise "missing project slug" unless params[:project_slug]
    @project = Project.find_by_slug(params[:project_slug])
    raise "Project.find failed" unless @project
  end

end
################################################################################
