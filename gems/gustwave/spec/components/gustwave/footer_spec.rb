# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Footer, type: :component do
  it_behaves_like "a component with configurable html attributes", selector: "footer"

  it "renders a footer element with the default classes" do
    render_inline(described_class.new)
    expect(rendered_content).to have_selector("footer.bg-white.dark\\:bg-gray-900")
    expect(rendered_content).not_to have_selector("footer.fixed")
  end

  it "renders the block inside the container" do
    render_inline(described_class.new) { "Copyright" }
    expect(rendered_content).to have_selector("footer > div.w-full.max-w-screen-xl.mx-auto.p-4", text: "Copyright")
  end

  context "with sticky" do
    it "fixes the footer to the bottom of the viewport" do
      render_inline(described_class.new(sticky: true)) { "Copyright" }
      expect(rendered_content).to have_selector("footer.fixed.bottom-0.left-0.z-20.w-full.border-t")
    end

    it "keeps the container classes off the sticky styles" do
      render_inline(described_class.new(sticky: true)) { "Copyright" }
      expect(rendered_content).to have_selector("footer > div.p-4")
      expect(rendered_content).not_to have_selector("footer > div.fixed")
    end
  end

  context "with container_options" do
    it "merges the given classes into the container" do
      render_inline(described_class.new(container_options: { class: "md:flex" })) { "Copyright" }
      expect(rendered_content).to have_selector("footer > div.md\\:flex.p-4")
    end

    it "lets its classes win conflicts with the container defaults" do
      render_inline(described_class.new(container_options: { class: "p-0" })) { "Copyright" }
      expect(rendered_content).to have_selector("footer > div.p-0")
      expect(rendered_content).not_to have_selector("footer > div.p-4")
    end
  end

  it "merges the caller's classes into the footer" do
    render_inline(described_class.new(class: "rounded-lg m-4")) { "Copyright" }
    expect(rendered_content).to have_selector("footer.rounded-lg.m-4.bg-white")
  end
end
