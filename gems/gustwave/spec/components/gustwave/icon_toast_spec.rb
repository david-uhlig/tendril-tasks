require "rails_helper"

RSpec.describe Gustwave::IconToast, type: :component do
  it_behaves_like "a text and block content renderer", selector: "div.ms-3"

  it "labels the icon in German" do
    I18n.with_locale(:de) { render_inline(described_class.new("Saved", status: :success)) }

    expect(rendered_content).to have_selector("span.sr-only", text: "Erfolg")
  end

  it "labels the icon in English" do
    I18n.with_locale(:en) { render_inline(described_class.new("Oops", status: :error)) }

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

    { success: :check_circle, failure: :close_circle, warning: :exclamation_circle, notice: :info_circle }.each do |status, icon|
      it "shows #{icon} for #{status}" do
        expected = paths_of(icon)
        render_inline(described_class.new("Hi", status:))

        expect(icon_paths("div.shrink-0 svg")).to eq expected
      end
    end

    it "shows a given icon instead" do
      expected = paths_of(:bell)
      render_inline(described_class.new("Hi", status: :success, icon: :bell))

      expect(icon_paths("div.shrink-0 svg")).to eq expected
    end
  end

  it "defaults to the info status" do
    render_inline(described_class.new("Hi"))

    expect(rendered_content).to have_selector("div.shrink-0.text-blue-500")
  end

  it "renders an empty label without a status" do
    render_inline(described_class.new("Plain", status: :none))

    expect(rendered_content).to have_selector("span.sr-only", text: "", exact_text: true, visible: :all)
  end

  describe "toast" do
    it "passes the id on to the toast" do
      render_inline(described_class.new("Hi", id: "my-toast"))

      expect(page).to have_selector("div#my-toast[role='alert']")
    end

    it "passes the position on to the toast" do
      render_inline(described_class.new("Hi", position: :top_right))

      expect(page).to have_selector("div[role='alert'].fixed.right-5")
    end

    it "passes dismissible: false on to the toast" do
      render_inline(described_class.new("Hi", dismissible: false))

      expect(page).not_to have_selector("button")
    end

    it "passes auto_remove on to the toast" do
      render_inline(described_class.new("Hi", auto_remove: true))

      expect(page).to have_selector("div[role='alert'][data-controller='gustwave--animate-and-remove']")
    end
  end
end
