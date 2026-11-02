require "rails_helper"

RSpec.describe Gustwave::Buttons::Default, type: :component do
  it_behaves_like "a button theme"

  %i[xs sm md lg xl].each do |size|
    it "renders #{size} without a fixed height" do
      render_inline(described_class.new("Go", size:))

      expect(page.find("button")["class"].split).not_to include("h-8", "h-9", "h-10", "h-12", "h-13")
    end
  end

  it "renders the disabled colour of the default color" do
    render_inline(described_class.new("Go"))

    expect(page).to have_selector('button.disabled\:bg-blue-400')
  end

  it "renders the Flowbite green" do
    render_inline(described_class.new("Go", color: :green))

    expect(page).to have_selector('button.bg-green-700.disabled\:bg-green-400')
  end
end
