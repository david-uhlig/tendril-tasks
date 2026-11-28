require "capybara/selenium/driver"

# Capybara 3.40.0 resets Chrome after each example with
# Storage.clearDataForOrigin(origin: "*"), which Chrome 158 rejects with
# "invalid argument: * is not a valid URL". Every JavaScript system spec then
# fails in its teardown. This clears the cookies of all origins instead, and
# the local storage of each origin the browser visited.
#
# spec/system/capybara_chrome_reset_spec.rb fails once Capybara stops sending
# the "*" origin or Chrome accepts it again. Delete this file then.
module CapybaraChromeReset
  def visit(url)
    uri = URI(url)
    visited_origins << uri.origin if uri.respond_to?(:origin)
    super
  end

  private

  def execute_cdp(cmd, params = {})
    return super unless cmd == "Storage.clearDataForOrigin" && params[:origin] == "*"

    types = params[:storageTypes].to_s.split(",")
    super("Network.clearBrowserCookies") if types.delete("cookies")
    visited_origins.each { |origin| super(cmd, origin:, storageTypes: types.join(",")) } if types.any?
    visited_origins.clear
  end

  def visited_origins
    @visited_origins ||= Set.new
  end
end

Capybara::Selenium::Driver::ChromeDriver.prepend(CapybaraChromeReset)
