# Be sure to restart your server when you modify this file
APP_NAME = "Devalot"
APP_HOME = "http://projects.noscience.net/devalot"

# Force all time objects to represent UTC/GMT
ENV['TZ'] = 'UTC'

# Uncomment below to force Rails into production mode when 
# you don't control web/app server and can't set it the proper way
# ENV['RAILS_ENV'] ||= 'production'

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.0.5' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.
  # See Rails::Configuration for more options.

  # Skip frameworks you're not going to use (only works if using vendor/rails).
  # To use Rails without a database, you must remove the Active Record framework
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Only load the plugins named here, in the order given. By default, all plugins 
  # in vendor/plugins are loaded in alphabetical order.
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )
  ['radius', 'redcloth', 'coderay'].each do |lib|
    config.load_paths << "#{RAILS_ROOT}/vendor/#{lib}/lib"
  end

  # Force all environments to use the same logger level 
  # (by default production uses :info, the others :debug)
  # config.log_level = :debug

  # Your secret key for verifying cookie session data integrity.
  # If you change this key, all old sessions will become invalid!
  # Make sure the secret is at least 30 characters and all random,
  # no regular words or you'll be exposed to dictionary attacks.
  config.action_controller.session = {
    :session_key => '_devalot_session',
    :secret      => 'c6f57c9af6ae2d70c9eabec90f3f50b4643dbbf8e69f7eb1409d62b32a349d210fbacb9e36841caeef5c3a5fa693a04f8a2adde7f8ad56df8043ff295ff3d5c6'
  }

  # Use the database for sessions instead of the cookie-based default,
  # which shouldn't be used to store highly confidential information
  # (create the session table with 'rake db:sessions:create')
  # config.action_controller.session_store = :active_record_store

  # Use SQL instead of Active Record's schema dumper when creating the test database.
  # This is necessary if your schema can't be completely dumped by the schema dumper, 
  # like if you have constraints or database-specific column types
  # config.active_record.schema_format = :sql

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector

  # Make Active Record use UTC-base instead of local time
  # config.active_record.default_timezone = :utc
end

# Add new inflection rules using the following format 
# (all these examples are active by default):
# Inflector.inflections do |inflect|
#   inflect.plural /^(ox)$/i, '\1en'
#   inflect.singular /^(ox)en/i, '\1'
#   inflect.irregular 'person', 'people'
#   inflect.uncountable %w( fish sheep )
# end

# Load the ferret configuration file
FERRET_CONFIG = YAML.load_file("#{RAILS_ROOT}/config/ferret.yml") rescue { 'ferret_search' => false }

# Include your application configuration below

require 'ostruct'
require 'digest/md5'
require 'digest/sha2'
require 'radius'
require 'redcloth'
require 'coderay'
require 'jcode'
# Added by Sam Lown - ensure gettext is loaded before
# all the libraries to ensure it can be used everywhere!
require "gettext/rails"
require "#{RAILS_ROOT}/lib/auth_helper"
require "#{RAILS_ROOT}/lib/authenticator"
require "#{RAILS_ROOT}/lib/commentable"
require "#{RAILS_ROOT}/lib/default_pages"
require "#{RAILS_ROOT}/lib/extend_tagging"
require "#{RAILS_ROOT}/lib/filtered"
require "#{RAILS_ROOT}/lib/has_filtered_text"
require "#{RAILS_ROOT}/lib/has_history"
require "#{RAILS_ROOT}/lib/has_watchers"
require "#{RAILS_ROOT}/lib/history_extensions"
require "#{RAILS_ROOT}/lib/icons"
require "#{RAILS_ROOT}/lib/notifier"
require "#{RAILS_ROOT}/lib/policy_callback"
require "#{RAILS_ROOT}/lib/projects_helper"
require "#{RAILS_ROOT}/lib/render_helper"
require "#{RAILS_ROOT}/lib/slug"
require "#{RAILS_ROOT}/lib/text_filter"
require "#{RAILS_ROOT}/lib/time_formater"
require "#{RAILS_ROOT}/lib/watcher_extensions"

# Add extensions
ActiveRecord::Base.extend HasFilteredText::ClassMethods
ActiveRecord::Base.extend HasWatchers::ClassMethods
ActiveRecord::Base.extend HasHistory::ClassMethods

# ActionMailer::Base.delivery_method = :smtp
# ActionMailer::Base.smtp_settings[:address] = "192.168.1.5"
