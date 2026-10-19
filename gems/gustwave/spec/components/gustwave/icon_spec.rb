# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Icon, type: :component do
  icons_dir = File.expand_path("../../../app/assets/images/gustwave/icons", __dir__)

  # The path data of the home icon's source file, to match the rendered <path>
  source_path_data = ->(theme) {
    File.read(File.join(icons_dir, theme, "home.svg"))[/ d="([^"]+)"/, 1]
  }

  it "renders the outline icon by default" do
    render_inline(described_class.new(:home))

    expect(rendered_content).to have_selector(
      "svg[fill='none'] path[stroke='currentColor'][d='#{source_path_data.call("outline")}']"
    )
    expect(rendered_content).to have_no_selector("svg[fill='currentColor']")
  end

  it "renders the solid icon" do
    render_inline(described_class.new(:home, theme: :solid))

    expect(rendered_content).to have_selector(
      "svg[fill='currentColor'] path[fill-rule='evenodd'][d='#{source_path_data.call("solid")}']"
    )
    expect(rendered_content).to have_no_selector("path[stroke]")
  end

  it "renders different markup for the outline and solid themes" do
    render_inline(described_class.new(:home))
    outline = rendered_content

    render_inline(described_class.new(:home, theme: :solid))

    expect(rendered_content).not_to eq(outline)
  end

  it "raises for an unknown theme" do
    expect { described_class.new(:home, theme: :duotone) }
      .to raise_error(Gustwave::Options::UnknownValueError, /Unknown value :duotone for :theme/)
  end
end
