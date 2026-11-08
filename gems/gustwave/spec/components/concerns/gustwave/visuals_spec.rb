require "rails_helper"

RSpec.describe Gustwave::Visuals, type: :component do
  { Gustwave::Buttons::Base => "h-5", Gustwave::Badge => "h-5" }.each do |component_class, lg_visual_height|
    describe component_class do
      it "declares the visual slots" do
        expect(component_class.extensible_slots.keys).to include(:leading_visuals, :trailing_visuals)
      end

      it "sizes visuals by the size variant" do
        render_inline(component_class.new("Go", size: :lg)) { |component| component.with_leading_visual_icon :close }

        expect(rendered_content).to have_selector("svg.#{lg_visual_height}.w-auto[aria-hidden='true']")
      end

      it "sizes indicators by the indicator_size derived value" do
        render_inline(component_class.new("Go", size: :lg)) { |component| component.with_trailing_visual_indicator }

        expect(rendered_content).to have_selector("span.h-4[aria-hidden='true']")
      end

      it "keeps a visual hidden when given other aria attributes" do
        render_inline(component_class.new("Go")) { |component| component.with_leading_visual_icon :close, aria: { label: "Close" } }

        expect(rendered_content).to have_selector("svg[aria-hidden='true'][aria-label='Close']")
      end

      it "shows a visual given aria: { hidden: false }" do
        render_inline(component_class.new("Go")) { |component| component.with_leading_visual_icon :close, aria: { hidden: false, label: "Close" } }

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

        render_inline(component_class.new("Go", size: :lg)) { |component| component.with_leading_visual_renderable(SizedVisual.new) }

        expect(rendered_content).to have_selector("span[data-size='lg']", text: "visual")
      end
    end
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

  describe "a component that places its own visuals" do
    let(:component_class) do
      Class.new(Gustwave::Component) do
        def self.name = "PlacedVisuals"

        include Gustwave::Visuals
        renders_visuals :visuals

        part :visual, "w-6 h-6"

        def call
          tag.div(safe_join(visuals), class: classes)
        end
      end
    end

    it "declares only the visuals slot, with every type" do
      expect(component_class.extensible_slots.keys).to eq([ :visuals ])
      expect(component_class.extensible_slots[:visuals][:types]).to include(:icon, :image, :svg, :indicator, :renderable)
    end

    it "has no has_visual toggle" do
      expect(component_class.option_definition.option(:has_visual)).to be_nil
    end

    it "sizes visuals by the visual part without a size variant" do
      render_inline(component_class.new) { |component| component.with_visual_icon :close }

      expect(rendered_content).to have_selector("div > svg.w-6.h-6[aria-hidden='true']")
    end

    it "renders several visuals" do
      render_inline(component_class.new) do |component|
        component.with_visual_icon :close
        component.with_visual_icon :edit
      end

      expect(rendered_content).to have_selector("div > svg[aria-hidden='true']", count: 2)
    end

    it "gives indicators their default size without an indicator_size value" do
      render_inline(component_class.new) { |component| component.with_visual_indicator }

      expect(rendered_content).to have_selector("div > span[aria-hidden='true']")
    end

    it "passes no size to custom visuals" do
      stub_const("SizedVisual", Class.new(Gustwave::Component) do
        def apply_slot_context(size:, **)
          @size = size
        end

        def call
          tag.span "visual", data: { size: @size.inspect }
        end
      end)

      render_inline(component_class.new) { |component| component.with_visual_renderable(SizedVisual.new) }

      expect(rendered_content).to have_selector("span[data-size='nil']")
    end
  end

  describe "visual_icon_theme" do
    let(:component_class) do
      Class.new(Gustwave::Component) do
        def self.name = "SolidVisuals"

        include Gustwave::Visuals
        renders_visuals :visuals
        self.visual_icon_theme = :solid

        def call
          safe_join(visuals)
        end
      end
    end

    it "defaults icons to the outline theme" do
      render_inline(Gustwave::Badge.new("Go")) { |badge| badge.with_leading_visual_icon :edit }

      expect(rendered_content).to have_selector("svg[fill='none']")
    end

    it "sets the theme of icons" do
      render_inline(component_class.new) { |component| component.with_visual_icon :edit }

      expect(rendered_content).to have_selector("svg[fill='currentColor']")
    end

    it "yields to a theme given to the icon" do
      render_inline(component_class.new) { |component| component.with_visual_icon :edit, theme: :outline }

      expect(rendered_content).to have_selector("svg[fill='none']")
    end
  end

  it "rejects other slot names" do
    expect do
      Class.new(Gustwave::Component) do
        include Gustwave::Visuals
        renders_visuals :icon
      end
    end.to raise_error(ArgumentError, /Unknown visual slots \[:icon\]/)
  end
end
