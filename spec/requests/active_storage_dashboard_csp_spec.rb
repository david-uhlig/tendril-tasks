# frozen_string_literal: true

require "rails_helper"
require "digest"

RSpec.describe "Active Storage Dashboard CSP", type: :request do
  let(:admin) { create(:user, :admin) }
  before { sign_in admin }

  # Once this spec fails, remove the ActiveStorageDashboard script-src's from
  # `initializers/content_security_policy.rb`.
  it "still needs at least one dashboard-only script hash" do
    get "/admin/monitoring/storage"

    expect(response).to have_http_status(:ok)

    policy = response.headers["Content-Security-Policy"] ||
             response.headers["Content-Security-Policy-Report-Only"]
    expect(policy).to be_present

    script_src = policy.split(";").map(&:strip).find { |directive| directive.start_with?("script-src ") }
    expect(script_src).to be_present

    hashes = script_src.scan(/'sha256-([^']+)'/).flatten
    expect(hashes).not_to be_empty

    nonces = script_src.scan(/'nonce-([^']+)'/).flatten
    scripts = Nokogiri::HTML(response.body).css("script:not([src])").filter_map do |script|
      next unless script["type"].blank? || script["type"] == "module"
      next if nonces.include?(script["nonce"])

      "sha256-#{Digest::SHA256.base64digest(script.text)}"
    end

    expect(scripts & hashes.map { |hash| "sha256-#{hash}" }).not_to be_empty, "No unnonced dashboard inline script matches a CSP hash; review and remove the dashboard-only hash allowances"
  end
end
