require File.dirname(__FILE__) + '/../test_helper'
require 'system_pages_controller'

# Re-raise errors caught by the controller.
class SystemPagesController; def rescue_action(e) raise e end; end

class SystemPagesControllerTest < Test::Unit::TestCase
  def setup
    @controller = SystemPagesController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  # Replace this with your real tests.
  def test_truth
    assert true
  end
end
