require "rails_helper"

RSpec.describe "Lookbook", type: :request do
  it "serves the explorer" do
    get "/lookbook"

    expect(response).to have_http_status(:ok)
  end

  it "inspects a Gustwave preview" do
    get "/lookbook/inspect/gustwave/tabs/default"

    expect(response).to have_http_status(:ok)
  end

  it "renders a Gustwave preview" do
    get "/lookbook/preview/gustwave/tabs/interactive"

    expect(response).to have_http_status(:ok)
    expect(response.body).to include('role="tablist"')
  end

  describe "the theme display option" do
    it "renders the preview in dark mode when dark" do
      get "/lookbook/preview/gustwave/tabs/default", params: { _display: { theme: "dark" }.to_json }

      expect(response.body).to match(/<html[^>]*class="dark"/)
    end

    it "renders the preview in light mode by default" do
      get "/lookbook/preview/gustwave/tabs/default"

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to match(/<html[^>]*class="dark"/)
    end

    it "leaves the plain ViewComponent preview route in light mode" do
      get "/rails/view_components/gustwave/tabs/default"

      expect(response).to have_http_status(:ok)
      expect(response.body).not_to match(/<html[^>]*class="dark"/)
    end
  end
end
