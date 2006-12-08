################################################################################
require File.dirname(__FILE__) + '/../test_helper'
################################################################################
class PolicyTest < Test::Unit::TestCase
  ################################################################################
  fixtures :policies
  
  ################################################################################
  def test_bool_policy
    assert(Policy.check(:true_bool_policy))
    assert(!Policy.check(:false_bool_policy))
  end

  ################################################################################
  def test_int_policy
    assert(Policy.check(:int_policy, 5))
    assert(Policy.check(:int_policy, lambda {|i| i == 5}))
  end

  ################################################################################
  def test_str_policy
    assert(Policy.check(:str_policy, "hello world"))
    assert(Policy.check(:str_policy, lambda {|s| s.match(/^hello world$/)}))
  end

end
################################################################################
