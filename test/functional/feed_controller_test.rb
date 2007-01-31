################################################################################
require File.dirname(__FILE__) + '/../test_helper'
require 'feed_controller'

################################################################################
# Re-raise errors caught by the controller.
class FeedController; def rescue_action(e) raise e end; end

################################################################################
class FeedControllerTest < Test::Unit::TestCase
  ################################################################################
  fixtures(:policies, :projects, :blogs, :articles, :tickets, :ticket_histories)

  ################################################################################
  def setup
    @controller = FeedController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  ################################################################################
  def test_all_articles
    %W(rss atom).each do |format|
      get("articles", {:blog => 'all', :format => format})
      assert_response(:success)
    end
  end

  ################################################################################
  def test_support_tickets
    %W(rss atom).each do |format|
      %W(all 1).each do |id|
        get("tickets", {
          :project => 'support', 
          :code    => 'w00tburger', 
          :format  => format,
          :id      => id,
        })

        assert_response(:success)
      end
    end
  end

end
################################################################################
