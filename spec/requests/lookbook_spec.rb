require "rails_helper"

RSpec.describe "Lookbook", type: :request do
  it "lands on the Flowbite coverage overview" do
    get "/lookbook"

    expect(response).to redirect_to("/lookbook/pages/coverage")

    follow_redirect!

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

  describe "the preview params" do
    let(:previews) { Lookbook::Engine.previews.to_a }

    it "exposes every keyword argument of a scenario" do
      missing = previews.flat_map do |preview|
        preview.scenarios.flat_map do |scenario|
          keywords = preview.preview_class.instance_method(scenario.name).parameters.filter_map { |type, name| name.to_s if type == :key }
          keywords.excluding(scenario.tags(:param).map(&:name)).map { "#{scenario.lookup_path} #{_1}" }
        end
      end

      expect(missing).to be_empty
    end

    it "renders every choice of every param" do
      failures = previews.flat_map(&:scenarios).flat_map do |scenario|
        scenario.tags(:param).flat_map do |tag|
          param = Lookbook::Param.from_tag(tag)
          values = param.input == "toggle" ? %w[true false] : Array(param.input_options[:choices])

          values.filter_map do |value|
            get "/lookbook/preview/#{scenario.lookup_path}", params: { param.name => value }
            "#{scenario.lookup_path}?#{param.name}=#{value} returned #{response.status}" unless response.ok?
          end
        end
      end

      expect(failures).to be_empty
    end

    it "treats a blank button color as the theme's default" do
      get "/lookbook/preview/gustwave/button/playground", params: { color: "" }

      expect(response).to have_http_status(:ok)
    end
  end
end
