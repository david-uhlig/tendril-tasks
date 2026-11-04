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
end
