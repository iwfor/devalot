################################################################################
require File.dirname(__FILE__) + '/../test_helper'
################################################################################
class ProjectTest < Test::Unit::TestCase
  ################################################################################
  fixtures :projects

  ################################################################################
  def test_basic_validations
    assert(!Project.new.valid?)
    assert(!Project.new(:name => 'One').valid?)
    assert(!Project.new(:slug => 'one').valid?)
    assert(Project.new(:name => 'One', :slug => 'one').valid?)
  end
end
################################################################################
