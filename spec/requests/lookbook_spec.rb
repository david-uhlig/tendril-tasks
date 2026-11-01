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
end
