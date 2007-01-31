################################################################################
require File.dirname(__FILE__) + '/../test_helper'
################################################################################
class ProjectTest < Test::Unit::TestCase
  ################################################################################
  fixtures :projects

  ################################################################################
  def test_basic_validations
    user = User.new

    assert(!Project.new.valid?)
    assert(!Project.new(:name => 'One').valid?)
    assert(!Project.new(:slug => 'one').valid?)

    valid_project = Project.new({
      :name => 'Kids with Guns',
      :slug => 'gorillaz',
      :summary => 'So bizarre, so bizarre',
    })

    assert(valid_project.valid?)
  end

end
################################################################################
