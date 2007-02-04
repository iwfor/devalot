################################################################################
require File.dirname(__FILE__) + '/../test_helper'

################################################################################
class StandardAuthenticatorTest < Test::Unit::TestCase
  ################################################################################
  def setup
    @authenticator = StandardAuthenticator

    @joe = @authenticator.create_account({
      :first_name => 'Joe',
      :last_name  => 'Test',
      :email      => 'AbC@example.com',
      :password   => 'foobar',
      :password2  => 'foobar',
    }, true)

    assert(@joe.respond_to?(:email))
    assert_equal('abc@example.com', @joe.email)
  end

  ################################################################################
  def teardown
    Account.destroy_all
  end

  ################################################################################
  def test_case_sensitivity
    [
      'abc@example.com',
      'Abc@example.com',
      'ABC@EXAMPLE.COM',
      ' ABC@ExAMPLE.COM ',

    ].each do |email|
      assert_equal(@joe, @authenticator.authenticate(:username => email, :password => 'foobar'))
    end
  end

  ################################################################################
  def test_password_check
    assert_equal(@joe, @authenticator.authenticate(:username => 'abc@example.com', :password => 'foobar'))
    assert_not_equal(@joe, @authenticator.authenticate(:username => 'abc@example.com', :password => 'foobars'))

    assert(@joe.password?('foobar'))
    assert(!@joe.password?('foobars'))
    assert(!@joe.password?('abc@example.com'))
    assert(!@joe.password?(''))

    # for now, this code should raise NoMethodError
    assert_raise(NoMethodError) {@joe.password?(nil)}
  end

  ################################################################################
  def test_activation_required
    pass  = 'I Love Richard Simions'
    email = 'j@s.tld'

    dude = @authenticator.create_account({
      :first_name => 'Jason',
      :last_name  => 'Scott',
      :email      => email,
      :password   => pass,
      :password2  => pass,
    }, false)

    assert(dude.respond_to?(:email))
    assert(dude.require_activation?)
    assert(!dude.enabled?)
    assert_not_equal(dude, @authenticator.authenticate(:username => email, :password => pass))
  end

end
################################################################################
