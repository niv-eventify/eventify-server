# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

## uncomment 2 following lines to debug autoloading
#require 'activesupport'
#ActiveSupport::Dependencies.log_activity = true

EXTRA_ENVIR_FILE = File.join(File.dirname(__FILE__), '/extra.rb')

NETPAY_MERCHANT_ID = 1415119 # demo, overide in extra.rb
NETPAY_SKIP_SSL = true

Rails::Initializer.run do |config|
  if "irb" == $0
    config.logger = Logger.new(STDOUT)
  end
  config.gem 'aws-s3', :version => '0.5.1', :lib => "aws/s3"
  config.gem 'authlogic', :version => '2.1.1'
  config.gem 'ruby-debug', :library => false
  rpass = (GlobalPreference.get(:rack_bug_password) || 'event123') rescue 'event123'
  config.middleware.use 'Rack::Bug', :password => rpass
  config.gem 'whenever', :lib => false, :source => 'http://gemcutter.org'
  config.gem 'will_paginate', :source => 'http://gemcutter.org'
  config.gem 'formtastic', :source => 'http://gemcutter.org', :version => "0.9.1"
  config.gem 'haml', :version => '>= 2.0.9'
  config.gem 'mocha', :version => '0.9.8', :library => false
  config.gem 'fast_gettext', :version => '0.4.17'
  config.gem "gettext", :lib => false, :version => '2.1.0'
  config.gem "grosser-pomo", :lib => false, :source=>"http://gems.github.com/", :version => '>=0.5.1'
  config.gem 'fastercsv', :lib => false, :version => '1.5.0'
  config.gem 'hoptoad_notifier', :version => "2.1.3"
  config.gem 'blackbook', :lib => false
  config.gem 'contacts', :lib => false, :version => "1.2.3"
  config.gem 'whenever', :lib => false, :source => 'http://gemcutter.org/'
  config.gem 'rspec-rails', :lib => false, :version => '1.3.2'
  config.gem 'rspec', :lib => false, :version => '1.3.0'
  config.gem "icalendar", :version => "1.1.4", :lib => false
  config.gem 'thinking-sphinx', :lib => 'thinking_sphinx', :version => '1.3.15'
  config.gem "json", :version => "1.2.0"
  config.gem "fastercsv", :version => '1.5.0'
  config.gem "rchardet", :version => '1.2'
  config.gem "parseexcel", :version => '0.5.2'
  config.gem "roo", :version => '1.3.9'
  config.gem "astrails-user-agent", :version => "1.0.0", :lib => "user-agent"
  config.gem "httparty", :version => '0.6.0'
  
  # Settings in config/environments/* take precedence over those specified here.
  # Application configuration should go into files in config/initializers
  # -- all .rb files in that directory are automatically loaded.

  # Add additional load paths for your own custom dirs
  # config.load_paths += %W( #{RAILS_ROOT}/extras )

  # Specify gems that this application depends on and have them installed with rake gems:install
  # config.gem "bj"
  # config.gem "hpricot", :version => '0.6', :source => "http://code.whytheluckystiff.net"
  # config.gem "sqlite3-ruby", :lib => "sqlite3"
  # config.gem "aws-s3", :lib => "aws/s3"

  # Only load the plugins named here, in the order given (default is alphabetical).
  # :all can be used as a placeholder for all plugins not explicitly named
  # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

  # Skip frameworks you're not going to use. To use Rails without a database,
  # you must remove the Active Record framework.
  # config.frameworks -= [ :active_record, :active_resource, :action_mailer ]

  # Activate observers that should always be running
  # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

  # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
  # Run "rake -D time" for a list of tasks for finding time zone names.
  config.time_zone = 'UTC'

  # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
  # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}')]
  # config.i18n.default_locale = :de
end