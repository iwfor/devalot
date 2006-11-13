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
    }

    description_attributes = {
      :body => 'My Project is the best project in the world.',
      :filter => 'Textile',
    }

   project = Project.create(user, project_attributes, description_attributes)
   assert(project.valid?)
   assert_equal(project.id, project.description.project_id)
   assert_equal(user.id, project.description.user_id)
   assert_equal("#{project.name} Description", project.description.title)
  end
end
################################################################################
