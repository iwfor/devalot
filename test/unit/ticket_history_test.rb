################################################################################
require File.dirname(__FILE__) + '/../test_helper'
################################################################################
class TicketHistoryTest < Test::Unit::TestCase
  fixtures(:ticket_histories, :users, :projects)

  ################################################################################
  def test_add_comment
    ticket = projects(:support).tickets.build({}, {:body => 'Test'}, users(:admin))
    assert(ticket.save)
    
    20.times do |i|
      c = ticket.comments.build
      c.user = users(:admin)
      c.build_filtered_text(:body => "Post #{i}")
      assert(c.save)
      ticket.comment_added(c)

      description = ticket.histories(true).last.description
      assert_kind_of(Array, description)
      assert_equal(1, description.length)
      assert_equal({:change=>"comment", :id=>c.id}, description.first)
    end
  end

end
################################################################################
