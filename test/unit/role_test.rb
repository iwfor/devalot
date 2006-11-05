################################################################################
require File.dirname(__FILE__) + '/../test_helper'
################################################################################
class RoleTest < Test::Unit::TestCase
  fixtures :roles

  ################################################################################
  # this is we only have to test one of the kids of PositionedAttribute
  def test_inheritance
    assert(Role.include?(PositionedAttribute))
  end

end
################################################################################
