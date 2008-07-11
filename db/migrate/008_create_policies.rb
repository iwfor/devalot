################################################################################
class CreatePolicies < ActiveRecord::Migration
  ##############################################################################
  class User < ActiveRecord::Base
    has_many :policies, :as => :policy
  end

  ##############################################################################
  def self.up
    create_table :policies do |t|
      t.integer :policy_id
      t.string  :policy_type
      t.string  :name
      t.string  :description
      t.string  :value
      t.string  :value_type
    end

    add_index :policies, [:policy_id, :policy_type, :name], :unique => true

    Policy.new(
      :name        => 'site_name', 
      :description => "The name of this installation of #APP_NAME",
      :value_type  => 'str',
      :value       => APP_NAME
    ).save!

    Policy.new(
      :name        => 'site_description', 
      :description => "A short (one line) description for this site",
      :value_type  => 'str',
      :value       => "Software projects that change the world"
    ).save!

    Policy.new(
      :name        => 'front_page_articles', 
      :description => "The number of blog articles to display on the front page",
      :value_type  => 'int',
      :value       => '5'
    ).save!

    Policy.new(
      :name        => 'feed_articles', 
      :description => "The number of blog articles to place in the RSS/Atom feeds",
      :value_type  => 'int',
      :value       => '10'
    ).save!

    Policy.new(
      :name        => 'authenticator', 
      :description => 'The user account authentication system to use',
      :value_type  => 'str',
      :value       => 'Standard'
    ).save!

    Policy.new(
      :name        => 'allow_open_enrollment',
      :description => 'If the current authenticator supports it, enable self-service account creation',
      :value_type  => 'bool',
      :value       => 'true'
    ).save!

    Policy.new(
      :name        => 'bot_from_email',
      :description => 'The from address for mail sent by a bot that can\'t accept reply mail',
      :value_type  => 'str',
      :value       => 'noreply@localhost.local'
    ).save!

    Policy.new(
      :name        => 'moderation_feed_code',
      :description => 'A secret code used by RSS/Atom feed readers to access the list of moderated users',
      :value_type  => 'str',
      :value       => Policy.random_code
    ).save!


    ############################################################################
    # Add user policies to existing users. (probably just admin at this point)
    User.find(:all).each do | user |
      user.policies.create({
        :name        => 'display_user_email', 
        :description => N_('Allow registered users to see your email address'),
        :value_type  => 'bool',
        :value       => 'true',
      })
    end
  end

  ##############################################################################
  def self.down
    drop_table :policies
  end

end
################################################################################
