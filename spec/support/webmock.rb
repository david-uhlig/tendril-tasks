# frozen_string_literal: true

require "webmock"
require "webmock/rspec/matchers"

# Blocks real HTTP requests in every spec, so a spec that calls out to a real
# host fails instead of passing quietly. Localhost stays open for the Capybara
# server and the browser driver in system tests.
WebMock.enable!
WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  config.include WebMock::API
  config.include WebMock::Matchers

  config.after(:each) { WebMock.reset! }
end
