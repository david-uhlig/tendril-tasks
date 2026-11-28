require "rails_helper"

# Guards spec/support/capybara_chrome_reset.rb. The patch is needed while
# Capybara resets Chrome with the "*" origin and Chrome rejects it. When either
# example below fails, delete the patch and this spec.
RSpec.describe "Capybara's Chrome reset", type: :system, js: true do
  let(:driver) { page.driver }

  it "still clears the storage of the * origin, which the patch replaces" do
    visit root_path # Capybara adds the Chrome reset once the browser runs
    allow(driver).to receive(:execute_cdp).and_call_original

    driver.reset!

    expect(driver).to have_received(:execute_cdp).with("Storage.clearDataForOrigin", hash_including(origin: "*")),
      "Capybara no longer resets Chrome with the * origin. Delete spec/support/capybara_chrome_reset.rb and this spec."
  end

  it "runs a Chrome that rejects the * origin" do
    version = driver.browser.capabilities.browser_version
    skip "Chrome #{version} still accepts the * origin; Chrome 158 rejects it" if version.to_i < 158

    expect { driver.browser.execute_cdp("Storage.clearDataForOrigin", origin: "*", storageTypes: "cookies") }
      .to raise_error(Selenium::WebDriver::Error::InvalidArgumentError, /not a valid URL/),
        "Chrome #{version} accepts the * origin again. Delete spec/support/capybara_chrome_reset.rb and this spec."
  end

  it "clears the cookies and the local storage of the visited origins" do
    visit root_path
    page.execute_script("localStorage.setItem('reset_probe', '1'); document.cookie = 'reset_probe=1; path=/'")

    driver.reset!
    visit root_path

    expect(page.evaluate_script("localStorage.getItem('reset_probe')")).to be_nil
    expect(page.evaluate_script("document.cookie")).not_to include("reset_probe")
  end
end
