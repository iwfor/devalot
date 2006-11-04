################################################################################
require File.dirname(__FILE__) + '/../test_helper'
################################################################################
class PriorityTest < Test::Unit::TestCase
  ################################################################################
  fixtures :priorities

  ################################################################################
  # this is we only have to test one of the kids of PositionedAttribute
  def test_inheritance
    assert(Priority.include?(PositionedAttribute))
  end

  ################################################################################
  def test_position
    priority = Priority.new('Fake Priority')
    assert_not_nil(priority.position)
  end

end
################################################################################
