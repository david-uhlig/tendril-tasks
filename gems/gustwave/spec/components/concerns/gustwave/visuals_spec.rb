require "rails_helper"

RSpec.describe Gustwave::Visuals, type: :component do
  [ Gustwave::Buttons::Base, Gustwave::Badge ].each do |component_class|
    describe component_class do
      it "includes Visuals" do
        expect(component_class.include?(Gustwave::Visuals)).to be(true)
      end

      it "declares the visual slots" do
        expect(component_class.extensible_slots.keys).to include(:leading_visuals, :trailing_visuals)
      end

      it "sizes visuals by the size variant" do
        render_inline(component_class.new("Go", size: :lg)) { |component| component.leading_icon :close }

        expect(rendered_content).to have_selector("svg.h-6.w-auto[aria-hidden='true']")
      end

      it "sizes indicators by the indicator_size derived value" do
        render_inline(component_class.new("Go", size: :lg)) { |component| component.trailing_indicator }

        expect(rendered_content).to have_selector("span[aria-hidden='true']")
      end

      it "keeps a visual hidden when given other aria attributes" do
        render_inline(component_class.new("Go")) { |component| component.leading_icon :close, aria: { label: "Close" } }

        expect(rendered_content).to have_selector("svg[aria-hidden='true'][aria-label='Close']")
      end

      it "shows a visual given aria: { hidden: false }" do
        render_inline(component_class.new("Go")) { |component| component.leading_icon :close, aria: { hidden: false, label: "Close" } }

        expect(rendered_content).to have_selector("svg[aria-label='Close']:not([aria-hidden='true'])")
      end

      it "passes its size to custom visuals" do
        stub_const("SizedVisual", Class.new(Gustwave::Component) do
          def apply_slot_context(size:, **)
            @size = size
          end

          def call
            tag.span "visual", data: { size: @size }
          end
        end)

        render_inline(component_class.new("Go", size: :lg)) { |component| component.leading_renderable(SizedVisual.new) }

        expect(rendered_content).to have_selector("span[data-size='lg']", text: "visual")
      end
    end
  end

  it "keeps Badge independent of the buttons" do
    expect(Gustwave::Badge.ancestors).not_to include(Gustwave::Buttons::Base)
  end

  it "doesn't extend the visuals of Badge when extending Buttons::Base" do
    expect(Gustwave::Badge.extensible_slots).not_to equal(Gustwave::Buttons::Base.extensible_slots)

    base = Gustwave::Buttons::Base
    extensible_slots = base.extensible_slots
    base.extend_slot :leading_visuals, types: { mark: ->(text) { tag.mark(text) } }

    expect(Gustwave::Badge.extensible_slots[:leading_visuals][:types]).not_to include(:mark)
  ensure
    base.extensible_slots = extensible_slots
    %i[with_leading_visual_mark with_leading_visual_mark_content build_slot_leading_visual_mark].each do |method_name|
      base.send(:remove_method, method_name)
    end
  end
end
