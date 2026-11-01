# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Icon, type: :component do
  icons_dir = File.expand_path("../../../app/assets/images/gustwave/icons", __dir__)

  # The path data of an icon's source file, to match the rendered <path>
  source_path_data = ->(theme, name = "home") {
    File.read(File.join(icons_dir, theme, "#{name}.svg"))[/ d="([^"]+)"/, 1]
  }

  it_behaves_like "a component with configurable html attributes", :home, selector: "svg"

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

  it "loads the file of an underscored name with dashes" do
    render_inline(described_class.new(:arrow_up))

    expect(rendered_content).to have_selector("svg path[d='#{source_path_data.call("outline", "arrow-up")}']")
  end

  it "renders the size" do
    render_inline(described_class.new(:home, size: :xs))

    expect(rendered_content).to have_selector("svg.h-4")
  end

  it "renders no margin by default" do
    render_inline(described_class.new(:home))

    expect(page.find("svg")[:class].split).not_to include(a_string_matching(/\Am[sexy]?-/))
  end

  it "renders the color" do
    render_inline(described_class.new(:home, color: :light))

    expect(rendered_content).to have_selector("svg.text-white")
  end

  it "renders the stroke width" do
    render_inline(described_class.new(:home, stroke_width: "2"))

    expect(rendered_content).to have_selector("svg[class~='*:stroke-2']")
  end
end
