require "rails_helper"

RSpec.describe "Lookbook's Flowbite coverage", type: :request do
  let(:coverage) { Gustwave::FlowbiteCoverage.current }

  describe "the overview" do
    before do
      get "/lookbook/pages"
      follow_redirect!
    end

    it "is the landing page, with the computed totals" do
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("<strong>#{coverage.possible_count}</strong>")
      expect(response.body).to include(coverage.in_scope_count.to_s)
    end

    it "links to a page, also one with a hyphen in its name" do
      expect(response.body).to include("/lookbook/pages/flowbite/components/device_mockups")
    end

    it "ranks what is missing" do
      expect(response.body).to include(coverage.gaps.first[:need])
    end
  end

  describe "the Flowbite pages" do
    it "shows every example of every page" do
      failures = coverage.page_keys.flat_map do |key|
        get "/lookbook/pages/flowbite/#{key.tr("-", "_")}"
        next [ "#{key} returned #{response.status}" ] unless response.ok?

        coverage.examples(key).filter_map do |example|
          "#{key} misses #{example.title}" unless response.body.include?(ERB::Util.html_escape(example.title))
        end
      end

      expect(failures).to be_empty
    end

    it "embeds a live preview of every example that has one" do
      get "/lookbook/pages/flowbite/components/tabs"

      expect(response.body.scan("<lookbook-embed").size).to eq(coverage.examples("components/tabs").count(&:preview))
      expect(response.body).to include("Gustwave::TabsPreview")
    end

    it "says what an example is waiting for" do
      get "/lookbook/pages/flowbite/components/tables"

      expect(response.body).to include("table-foot")
    end
  end

  describe "the Flowbite panel" do
    it "lists the examples a scenario reproduces" do
      get "/lookbook/inspect/gustwave/tabs/default"

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Reproduces these Flowbite examples")
      expect(response.body).to include("Default tabs")
    end

    it "lists nothing for a scenario without examples" do
      get "/lookbook/inspect/gustwave/icon/gallery"

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to include("Default tabs")
    end
  end
end
