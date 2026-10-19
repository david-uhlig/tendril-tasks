require "rails_helper"

RSpec.describe Gustwave::Buttons::Base, type: :component do
  with_options selector: "button[type='button']" do
    it_behaves_like "a text and block content renderer"
    it_behaves_like "a component with configurable html attributes"
  end

  context "with default options" do
    before(:context) do
      render_inline(described_class.new) { "content" }
    end

    it "renders base styling" do
      expect(rendered_content).to have_selector("button.rounded-lg")
    end

    it "renders default size styling" do
      expect(rendered_content).to have_selector("button.px-5")
    end

    it "renders no pill styling" do
      expect(rendered_content).not_to have_selector("button.rounded-full")
    end

    it "renders no leading/trailing visual styling" do
      expect(rendered_content).not_to have_selector("button.inline-flex")
    end
  end

  context "with tag argument" do
    it "renders an anchor tag" do
      render_inline(described_class.new(tag: :a)) { "anchor_content" }

      expect(rendered_content).to have_selector("a", text: "anchor_content")
    end
  end

  context "with color argument" do
    it "renders no base styling when color is set to :none" do
      render_inline(described_class.new(color: :none)) { "content" }

      expect(rendered_content).not_to have_selector("button.rounded-lg")
    end
  end

  context "with size argument" do
    it "renders custom size styling" do
      render_inline(described_class.new(size: :xl)) { "content" }

      expect(rendered_content).to have_selector("button.px-6")
    end
  end

  context "with pill argument" do
    it "renders pill styling" do
      render_inline(described_class.new(pill: true)) { "content" }

      expect(rendered_content).to have_selector("button.rounded-full")
    end
  end

  context "with a leading and a trailing visual around the text" do
    it "renders the leading visual before the text and the trailing visual after it" do
      render_inline(described_class.new("Go")) do |component|
        component.with_leading_visual_icon :check
        component.with_trailing_visual_icon :check
      end

      expect(page).to have_xpath("//button/svg[1][following-sibling::text()[normalize-space()='Go']]")
      expect(page).to have_xpath("//button/svg[2][preceding-sibling::text()[normalize-space()='Go']]")
    end
  end

  %i[leading trailing].each do |position|
    context "with a #{position} visual" do
      # The text sits on the other side of the visual
      sibling = position == :leading ? "following-sibling" : "preceding-sibling"

      {
        "icon" => [ "svg", ->(component) { component.public_send(:"with_#{position}_visual_icon", :check) } ],
        "image" => [ "img", ->(component) { component.public_send(:"with_#{position}_visual_image", "https://example.com/image.png") } ],
        "svg" => [ "svg", ->(component) { component.public_send(:"with_#{position}_visual_svg", "gustwave/icons/outline/arrow-left.svg") } ]
      }.each do |kind, (element, add_visual)|
        it "renders the #{kind} #{position} of the text" do
          render_inline(described_class.new("Go")) { |component| add_visual.call(component) }

          expect(page).to have_xpath("//button/#{element}[#{sibling}::text()[normalize-space()='Go']]")
        end
      end

      it "renders the visual classes" do
        render_inline(described_class.new) do |component|
          component.public_send(:"with_#{position}_visual_icon", :check)
        end

        expect(rendered_content).to have_selector("button.inline-flex")
      end

      it "merges a custom class with the visual size classes on images" do
        render_inline(described_class.new) do |component|
          component.public_send(:"with_#{position}_visual_image", "https://example.com/image.png", class: "custom")
        end

        expect(rendered_content).to have_selector("button>img.h-5.w-auto.custom[aria-hidden='true']")
      end

      it "merges a custom class with the visual size classes on svgs" do
        render_inline(described_class.new) do |component|
          component.public_send(:"with_#{position}_visual_svg", "gustwave/icons/outline/arrow-left.svg", class: "custom")
        end

        expect(rendered_content).to have_selector("button>svg.h-5.w-auto.custom")
      end

      it "merges a custom class with the visual size classes on block svgs" do
        render_inline(described_class.new) do |component|
          component.public_send(:"with_#{position}_visual_svg", class: "custom") do
            '<svg xmlns="http://www.w3.org/2000/svg"><rect width="1" height="1"/></svg>'.html_safe
          end
        end

        expect(rendered_content).to have_selector("button>svg.h-5.w-auto.custom[aria-hidden='true']>rect")
      end
    end
  end

  context "with an indicator" do
    {
      [ described_class, :xs ] => "h-3",
      [ described_class, :xl ] => "h-6",
      [ Gustwave::Buttons::Inline, :"3xs" ] => "h-\\[1em\\]",
      [ Gustwave::Badge, :"2xl" ] => "h-\\[1em\\]"
    }.each do |(component, size), height|
      it "sizes it for a #{size} #{component.name.demodulize}" do
        render_inline(component.new("Text", size:)) { |button| button.with_trailing_visual_indicator "3" }

        expect(rendered_content).to have_selector("span.#{height}[aria-hidden='true']", text: "3")
      end
    end
  end

  context "with leading visual without content" do
    it "overwrites padding" do
      render_inline(described_class.new) do |component|
        component.with_leading_visual_icon :check
      end

      expect(rendered_content).to have_selector('button.p-2\.5')
    end

    it "keeps the text padding when the button has text" do
      render_inline(described_class.new("Go")) do |component|
        component.with_leading_visual_icon :check
      end

      expect(rendered_content).not_to have_selector('button.p-2\.5')
    end
  end

  context "with a renderable visual" do
    let(:consumer_avatar) do
      stub_const("ConsumerAvatar", Class.new(Gustwave::Component) {
        def initialize(src) = @src = src

        def apply_slot_context(size:, html_attributes:, **)
          @size = size
          @html_attributes = html_attributes
        end

        def call
          image_tag @src, **configure_html_attributes({ class: "rounded-full" }, **@html_attributes.to_h), data: { size: @size }
        end
      })
    end

    %i[leading trailing].each do |position|
      it "applies the button's visual context to a #{position} component" do
        render_inline(described_class.new("Me", size: :lg)) do |component|
          component.public_send(:"with_#{position}_visual_renderable", consumer_avatar.new("https://example.com/me.png"))
        end

        expect(rendered_content).to have_selector(
          "button>img.h-6.w-auto.rounded-full[aria-hidden='true'][data-size='lg'][src='https://example.com/me.png']"
        )
      end
    end

    it "applies the visual context of the gradient duotone theme" do
      render_inline(Gustwave::Button.for(:gradient_duotone).new("Me", size: :sm)) do |button|
        button.with_leading_visual_renderable(consumer_avatar.new("https://example.com/me.png"))
      end

      expect(rendered_content).to have_selector("button>img.h-5.w-auto[data-size='sm']")
    end

    it "renders components without the protocol unchanged" do
      render_inline(described_class.new("Me")) do |component|
        component.with_leading_visual_renderable(Gustwave::Avatar.new(src: "https://example.com/me.png", size: :xs))
      end

      expect(rendered_content).to have_selector("button img[src='https://example.com/me.png']")
    end
  end

  context "with a tag and type" do
    it "renders a link without a type" do
      render_inline(described_class.new(tag: :a, type: :submit, href: "#")) { "content" }

      expect(page).to have_selector("a[href='#']")
      expect(page).not_to have_selector("[type]")
    end

    it "renders the given type" do
      render_inline(described_class.new(type: :submit)) { "content" }

      expect(page).to have_selector("button[type='submit']")
    end
  end
end
