require "rails_helper"

RSpec.describe Gustwave::Buttons::DefaultOutline, type: :component do
  it_behaves_like "a button theme"

  it "renders the Flowbite green" do
    render_inline(described_class.new("Go", color: :green))

    expect(page).to have_selector("button.text-green-700")
  end
end
