require "rails_helper"

class SingleSetSlotsComponent < Gustwave::Component
  renders_one :title, ->(text) { text }
  renders_many :sections, ->(text) { text }
  renders_one :visual, types: {
    icon: ->(name) { name },
    text: ->(text) { text }
  }

  def call
    safe_join([ title, *sections, visual ].compact)
  end
end

RSpec.describe Gustwave::Test::SingleSetSlots, type: :component do
  it "is prepended to ViewComponent::Base in specs" do
    expect(ViewComponent::Base.ancestors).to include(described_class)
  end

  it "allows setting a renders_one slot once" do
    render_inline(SingleSetSlotsComponent.new) do |component|
      component.with_title("Title")
    end

    expect(rendered_content).to eq("Title")
  end

  it "raises when a renders_one slot is set twice" do
    expect {
      render_inline(SingleSetSlotsComponent.new) do |component|
        component.with_title("First")
        component.with_title("Second")
      end
    }.to raise_error(described_class::SlotAlreadySetError, /SingleSetSlotsComponent .* `title`/)
  end

  it "raises when with_*_content follows the setter" do
    expect {
      render_inline(SingleSetSlotsComponent.new) do |component|
        component.with_title("First")
        component.with_title_content("Second")
      end
    }.to raise_error(described_class::SlotAlreadySetError)
  end

  it "allows setting a renders_many slot repeatedly" do
    render_inline(SingleSetSlotsComponent.new) do |component|
      component.with_section("One")
      component.with_section("Two")
    end

    expect(rendered_content).to eq("OneTwo")
  end

  it "leaves ViewComponent's own error for polymorphic renders_one slots" do
    expect {
      render_inline(SingleSetSlotsComponent.new) do |component|
        component.with_visual_icon("star")
        component.with_visual_text("Star")
      end
    }.to raise_error(ViewComponent::ContentAlreadySetForPolymorphicSlotError)
  end
end
