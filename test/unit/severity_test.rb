################################################################################
require File.dirname(__FILE__) + '/../test_helper'
################################################################################
class SeverityTest < Test::Unit::TestCase
  ################################################################################
  fixtures :severities

  ################################################################################
  # this is we only have to test one of the kids of PositionedAttribute
  def test_inheritance
    assert(Severity.include?(PositionedAttribute))
  end

end
################################################################################
