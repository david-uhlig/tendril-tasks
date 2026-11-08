# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Toast, type: :component do
  it "is dismissible by default" do
    expect(described_class.new("text")).to be_dismissible
  end

  [ nil, true, "true" ].each do |dismissible|
    it "is dismissible with dismissible: #{dismissible.inspect}" do
      expect(described_class.new("text", dismissible:)).to be_dismissible
    end
  end

  [ false, "false", "0" ].each do |dismissible|
    it "isn't dismissible with dismissible: #{dismissible.inspect}" do
      expect(described_class.new("text", dismissible:)).not_to be_dismissible
    end
  end

  describe "attributes" do
    def toast(**options)
      render_inline(described_class.new("text", **options))
      page.find("[role=alert]")
    end

    it "wires no Stimulus controller by default" do
      expect(toast["data-controller"]).to be_nil
      expect(toast["data-action"]).to be_nil
    end

    it "wires the shipped controller with auto_remove" do
      el = toast(auto_remove: true)

      expect(el["data-controller"]).to eq "gustwave--animate-and-remove"
      expect(el["data-action"]).to eq "mouseover->gustwave--animate-and-remove#pause mouseout->gustwave--animate-and-remove#continue"
    end

    it "keeps a caller's controller and actions next to it" do
      el = toast(auto_remove: true, data: { controller: "other", action: "click->other#go" })

      expect(el["data-controller"]).to eq "other gustwave--animate-and-remove"
      expect(el["data-action"]).to start_with "click->other#go "
    end

    it "passes other attributes through and merges classes" do
      el = toast(class: "mt-2", aria: { live: "polite" }, data: { test: "x" })

      expect(el["aria-live"]).to eq "polite"
      expect(el["data-test"]).to eq "x"
      expect(el[:class]).to include("mt-2", "shadow-sm")
    end
  end

  describe "position" do
    it "renders a fixed position" do
      render_inline(described_class.new("text", position: :top_right))

      expect(page).to have_selector("div[role='alert'].fixed.right-5")
    end
  end

  describe "dismiss button" do
    it "renders a button dismissing the toast" do
      render_inline(described_class.new("text", id: "my-toast"))

      expect(page).to have_selector("div#my-toast > button[data-dismiss-target='#my-toast'][aria-label='Dismiss'].h-8.w-8")
    end

    it "targets the generated id with the dismiss button" do
      render_inline(described_class.new("text"))
      id = page.find("div[role='alert']")["id"]

      expect(id).to start_with("toast-")
      expect(page).to have_selector("div##{id} > button[data-dismiss-target='##{id}']")
    end

    it "renders no button when not dismissible" do
      render_inline(described_class.new("text", dismissible: false))

      expect(page).not_to have_selector("button")
    end

    it "keeps the button at the end of the row" do
      render_inline(described_class.new("text"))

      expect(page).to have_selector("button.ms-auto.shrink-0")
    end

    it "renders the button once where the block places it" do
      render_inline(described_class.new(id: "my-toast")) do |toast|
        %(<div class="row">#{toast.dismiss_button}</div>).html_safe
      end

      expect(page).to have_selector("div#my-toast > div.row > button[data-dismiss-target='#my-toast']")
      expect(page).to have_selector("button", count: 1)
    end

    it "customizes the button with with_dismiss_button" do
      render_inline(described_class.new("text", id: "my-toast")) do |toast|
        toast.with_dismiss_button(text: "Close notification")
      end

      expect(page).to have_selector("button[data-dismiss-target='#my-toast'][aria-label='Close notification'] > span.sr-only", text: "Close notification")
    end

    it "customizes the button placed by the block" do
      render_inline(described_class.new(id: "my-toast")) do |toast|
        toast.with_dismiss_button("Close notification")
        %(<div class="row">#{toast.dismiss_button}</div>).html_safe
      end

      expect(page).to have_selector("div#my-toast > div.row > button[aria-label='Close notification']")
      expect(page).to have_selector("button", count: 1)
    end

    it "renders the customized button once, not again at the end" do
      render_inline(described_class.new(id: "my-toast")) do |toast|
        toast.with_dismiss_button(text: "Close notification")
        %(<div class="row">#{toast.dismiss_button}</div>).html_safe
      end

      expect(page).to have_selector("button", count: 1)
    end

    it "renders no button with dismissible: false, even when the block places one" do
      render_inline(described_class.new(id: "my-toast", dismissible: false)) do |toast|
        %(<div class="row">#{toast.dismiss_button}</div>).html_safe
      end

      expect(page).not_to have_selector("button")
    end

    it "renders no button with dismissible: false, even when one is set" do
      render_inline(described_class.new("text", dismissible: false)) do |toast|
        toast.with_dismiss_button(text: "Close notification")
      end

      expect(page).not_to have_selector("button")
    end
  end

  describe "status" do
    it_behaves_like "a text and block content renderer", selector: "div.ms-3", status: :success

    def icon_paths(selector)
      Nokogiri::HTML.fragment(rendered_content).at_css(selector).css("path").map { _1["d"] }
    end

    def paths_of(icon)
      render_inline(Gustwave::Icon.new(icon, theme: :solid))
      icon_paths("svg")
    end

    { info: :info_circle, notice: :info_circle, success: :check_circle, error: :close_circle,
      failure: :close_circle, warning: :exclamation_circle, alert: :exclamation_circle }.each do |status, icon|
      it "shows the solid #{icon} for #{status}" do
        expected = paths_of(icon)
        render_inline(described_class.new("Hi", status:))

        expect(icon_paths("div.shrink-0.w-8 > svg[aria-hidden='true']")).to eq expected
      end
    end

    it "colors the visual box by status" do
      render_inline(described_class.new("Hi", status: :error))

      expect(rendered_content).to have_selector("div[role='alert'] > div.shrink-0.text-red-500.bg-red-100")
    end

    it "names the status for screen readers in English" do
      I18n.with_locale(:en) { render_inline(described_class.new("Oops", status: :error)) }

      expect(rendered_content).to have_selector("div.shrink-0 > span.sr-only", text: "Error")
    end

    it "names the status for screen readers in German" do
      I18n.with_locale(:de) { render_inline(described_class.new("Saved", status: :success)) }

      expect(rendered_content).to have_selector("div.shrink-0 > span.sr-only", text: "Erfolg")
    end

    it "renders no visual box, label or message wrapper without a status" do
      render_inline(described_class.new("Plain"))

      expect(rendered_content).not_to have_selector("div.shrink-0")
      expect(rendered_content).not_to have_selector("div[role='alert'] > div > span.sr-only")
      expect(rendered_content).not_to have_selector("div.ms-3")
      expect(rendered_content).to have_selector("div[role='alert']", text: "Plain")
    end

    it "keeps the dismiss button after the message" do
      render_inline(described_class.new("Hi", status: :success))

      expect(rendered_content).to have_selector("div[role='alert'] > div.ms-3 + button")
    end
  end

  describe "visuals" do
    it "replaces the status's icon with icon:" do
      expected = paths_of(:bell)
      render_inline(described_class.new("Hi", status: :success, icon: :bell))

      expect(icon_paths("div.shrink-0 > svg")).to eq expected
    end

    it "replaces the status's icon with a visual set in the block" do
      render_inline(described_class.new("Hi", status: :success)) { |toast| toast.with_visual_icon(:bell, theme: :outline) }

      expect(rendered_content).to have_selector("div.shrink-0.text-green-500 > svg[fill='none']", count: 1)
      expect(rendered_content).to have_selector("div.shrink-0 > span.sr-only", text: "Success")
    end

    it "renders a visual without a status, in an uncolored box without a label" do
      render_inline(described_class.new("Hi")) { |toast| toast.with_visual_renderable(Gustwave::Icon.new(:bell, class: "text-purple-500")) }

      expect(rendered_content).to have_selector("div.shrink-0.w-8 > svg.text-purple-500")
      expect(rendered_content).not_to have_selector("div.shrink-0 > span.sr-only")
      expect(rendered_content).to have_selector("div.ms-3", text: "Hi")
    end

    it "renders the icon from icon: in solid by default" do
      render_inline(described_class.new("Hi", icon: :bell))

      expect(rendered_content).to have_selector("div.shrink-0 > svg[fill='currentColor']")
    end

    def icon_paths(selector)
      Nokogiri::HTML.fragment(rendered_content).at_css(selector).css("path").map { _1["d"] }
    end

    def paths_of(icon)
      render_inline(Gustwave::Icon.new(icon, theme: :solid))
      icon_paths("svg")
    end
  end
end
