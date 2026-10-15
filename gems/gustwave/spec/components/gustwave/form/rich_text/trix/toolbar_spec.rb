# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::RichText::Trix::Toolbar, type: :component do
  def toolbar
    page.find("trix-toolbar")
  end

  it "renders a trix-toolbar with the given id" do
    render_inline(described_class.new(nil, id: "my-toolbar"))

    expect(toolbar["id"]).to eq("my-toolbar")
  end

  it "generates a unique id for each toolbar without an id" do
    ids = 2.times.map do
      render_inline(described_class.new(nil))
      toolbar["id"]
    end

    expect(ids).to all(start_with("toolbar-"))
    expect(ids.uniq.size).to eq(2)
  end

  it "passes HTML attributes to the surrounding element" do
    render_inline(described_class.new(nil, class: "my-toolbar", data: { test: "toolbar" }))

    expect(page).to have_css("div.my-toolbar[data-test='toolbar'] > trix-toolbar")
  end
end
