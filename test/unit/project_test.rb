################################################################################
require File.dirname(__FILE__) + '/../test_helper'
################################################################################
class ProjectTest < Test::Unit::TestCase
  ################################################################################
  fixtures :projects

  ################################################################################
  def test_basic_validations
    user = User.new

    assert(!Project.new(user).valid?)
    assert(!Project.new(user, :name => 'One').valid?)
    assert(!Project.new(user, :slug => 'one').valid?)

    valid_project = Project.new(user, {
      :name => 'Kids with Guns',
      :slug => 'gorillaz',
      :summary => 'So bizarre, so bizarre',
    }, {
      :body => 'Wow',
      :filter => 'None',
    })

    assert(valid_project.valid?)
  end
  
  ################################################################################
  def test_create
    user = User.create({
      :first_name => 'John',
      :last_name  => 'Doe',
      :email      => 'johndoe@example.com',
    })

    assert(user.valid?)

    project_attributes = {
      :name => 'My Project',
      :slug => 'my-project',
      :summary => 'Oh how I love to make software',
    }

    description_attributes = {
      :body => 'My Project is the best project in the world.',
      :filter => 'Textile',
    }

   project = Project.new(user, project_attributes, description_attributes)
   assert(project.save)
   assert_equal(user.id, project.description.created_by_id)
   assert_equal(user.id, project.description.updated_by_id)
  end
end
################################################################################
