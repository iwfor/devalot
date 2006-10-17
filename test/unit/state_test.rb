################################################################################
require File.dirname(__FILE__) + '/../test_helper'
################################################################################
class StateTest < Test::Unit::TestCase
  ################################################################################
  fixtures :states

  ################################################################################
  # this is we only have to test one of the kids of PositionedAttribute
  def test_inheritance
    assert(State.include?(PositionedAttribute))
  end

  ################################################################################
  def test_position
    state = State.new('Fake State')
    assert_not_nil(state.position)
  end

end
################################################################################
