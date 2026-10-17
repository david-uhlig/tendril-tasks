require "rails_helper"

# Consumers extend the visuals of every button theme at once by extending
# Gustwave::Buttons::Base, e.g. in an initializer.
RSpec.describe "Extending Gustwave::Buttons::Base", type: :component do
  themes = {
    default: Gustwave::Buttons::Default,
    default_outline: Gustwave::Buttons::DefaultOutline,
    gradient_monochrome: Gustwave::Buttons::GradientMonochrome,
    gradient_monochrome_colored_shadow: Gustwave::Buttons::GradientMonochromeColoredShadow,
    gradient_duotone: Gustwave::Buttons::GradientDuotone,
    gradient_duotone_outline: Gustwave::Buttons::GradientDuotoneOutline,
    inline: Gustwave::Buttons::Inline
  }.freeze

  around do |example|
    base = Gustwave::Buttons::Base
    extensible_slots = base.extensible_slots

    base.extend_slot :leading_visuals, types: {
      badge: ->(text) { tag.mark(text, **configure_visual_html_attributes({ class: "badge" })) }
    }
    example.run
  ensure
    base.extensible_slots = extensible_slots
    %i[with_leading_visual_badge with_leading_visual_badge_content build_slot_leading_visual_badge].each do |method_name|
      base.send(:remove_method, method_name)
    end
  end

  it "covers every registered button theme" do
    expect(Gustwave::Button.themes.values.uniq).to match_array(themes.values)
  end

  themes.each do |theme_name, theme_class|
    it "adds the type to #{theme_class.name}" do
      render_inline(theme_class.new("Go", size: :lg)) do |button|
        button.with_leading_visual_badge("new")
      end

      expect(rendered_content).to have_selector("mark.badge.h-6.w-auto[aria-hidden='true']", text: "new")
      expect(theme_class.extensible_slots[:leading_visuals][:types]).to include(:badge)
    end

    it "adds the type to Gustwave::Button with the #{theme_name} theme" do
      render_inline(Gustwave::Button.for(theme_name).new("Go")) do |button|
        button.with_leading_visual(:badge, "new")
      end

      expect(rendered_content).to have_selector("mark.badge", text: "new")
    end
  end

  it "keeps the built-in types" do
    render_inline(Gustwave::Buttons::Default.new("Go")) do |button|
      button.with_leading_visual_badge("new")
      button.with_leading_visual_icon :dismiss
    end

    expect(rendered_content).to have_selector("mark.badge + svg")
  end
end
