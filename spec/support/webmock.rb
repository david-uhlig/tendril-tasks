# frozen_string_literal: true

require "webmock"
require "webmock/rspec/matchers"

# Stubs HTTP requests only in examples tagged with `:webmock`, so system tests
# keep talking to the browser driver.
WebMock.disable!

RSpec.configure do |config|
  config.include WebMock::API, :webmock
  config.include WebMock::Matchers, :webmock

  config.around(:each, :webmock) do |example|
    WebMock.enable!
    WebMock.disable_net_connect!
    example.run
  ensure
    WebMock.reset!
    WebMock.allow_net_connect!
    WebMock.disable!
  end
end
