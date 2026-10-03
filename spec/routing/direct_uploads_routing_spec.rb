# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Active Storage direct uploads routing", type: :routing do
  # Lexxy posts to `rails_direct_uploads_url`, so that path must never reach the
  # unauthenticated `ActiveStorage::DirectUploadsController`.
  it "routes direct uploads to the restricted controller" do
    expect(post: rails_direct_uploads_path).to route_to("restricted_direct_uploads#create")
  end
end
