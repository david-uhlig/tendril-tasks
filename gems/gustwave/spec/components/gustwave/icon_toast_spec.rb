require "rails_helper"

RSpec.describe Gustwave::IconToast, type: :component do
  it "labels the icon in German" do
    I18n.with_locale(:de) { render_inline(described_class.new("Saved", scheme: :success)) }

    expect(rendered_content).to have_selector("span.sr-only", text: "Erfolg")
  end

  it "labels the icon in English" do
    I18n.with_locale(:en) { render_inline(described_class.new("Oops", scheme: :error)) }

    expect(rendered_content).to have_selector("span.sr-only", text: "Error")
  end

  describe "icon" do
    def icon_paths(selector = "svg")
      Nokogiri::HTML.fragment(rendered_content).at_css(selector).css("path").map { _1["d"] }
    end

    def paths_of(icon)
      render_inline(Gustwave::Icon.new(icon))
      icon_paths
    end

    { success: :check_circle, failure: :close_circle, warning: :exclamation_circle, notice: :info_circle }.each do |scheme, icon|
      it "shows #{icon} for #{scheme}" do
        expected = paths_of(icon)
        render_inline(described_class.new("Hi", scheme:))

        expect(icon_paths("div.shrink-0 svg")).to eq expected
      end
    end

    it "shows a given icon instead" do
      expected = paths_of(:bell)
      render_inline(described_class.new("Hi", scheme: :success, icon: :bell))

      expect(icon_paths("div.shrink-0 svg")).to eq expected
    end
  end

  it "defaults to the info scheme" do
    render_inline(described_class.new("Hi"))

    expect(rendered_content).to have_selector("div.shrink-0.text-blue-500")
  end

  it "renders an empty label without a scheme" do
    render_inline(described_class.new("Plain", scheme: :none))

    expect(rendered_content).to have_selector("span.sr-only", text: "", exact_text: true, visible: :all)
  end
end
