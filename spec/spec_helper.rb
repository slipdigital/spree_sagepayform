# Configure Rails Environment
ENV['RAILS_ENV'] = 'test'

# require File.expand_path('../dummy/config/environment.rb',  __FILE__)

require 'rspec'
require 'ffaker'
require 'spree'
require 'spree/core'
require 'factory_girl'
require 'spree_gateway'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.join(File.dirname(__FILE__), 'support/**/*.rb')].each { |f| require f }

require 'spree/core/url_helpers'

RSpec.configure do |config|
  config.include FactoryGirl::Syntax::Methods
  config.include Spree::Core::UrlHelpers
  config.mock_with :rspec
end
