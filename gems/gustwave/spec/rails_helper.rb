# frozen_string_literal: true

require "spec_helper"
ENV["RAILS_ENV"] ||= "test"
require_relative "dummy/config/environment"
require "rspec/rails"
require "view_component/test_helpers"
require "capybara/rspec"

ActiveRecord::Migration.verbose = false
load File.join(__dir__, "dummy/db/schema.rb")

Dir[File.join(__dir__, "support/**/*.rb")].each { |f| require f }

RSpec.configure do |config|
  config.include ViewComponent::TestHelpers, type: :component
  config.include Capybara::RSpecMatchers, type: :component

  config.filter_rails_from_backtrace!
end
