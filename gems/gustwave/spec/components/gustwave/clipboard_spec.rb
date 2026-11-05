require "rails_helper"

RSpec.describe Gustwave::Clipboard, type: :component do
  describe "wiring" do
    it "points the button at the element to copy" do
      render_inline(described_class.new("Copy", target_id: "npm-install"))

      expect(page).to have_selector("button[type='button'][data-copy-to-clipboard-target='npm-install']")
    end

    it "wires the Stimulus controller and its copied action" do
      render_inline(described_class.new("Copy", target_id: "npm-install"))

      expect(page).to have_selector("button[data-controller='gustwave--clipboard'][data-action='click->gustwave--clipboard#copied']")
    end

    it "passes the reset delay to the controller" do
      render_inline(described_class.new("Copy", target_id: "npm-install", reset_after: 500))

      expect(page).to have_selector("button[data-gustwave--clipboard-reset-after-value='500']")
    end

    it "defaults the reset delay to two seconds" do
      render_inline(described_class.new("Copy", target_id: "npm-install"))

      expect(page).to have_selector("button[data-gustwave--clipboard-reset-after-value='2000']")
    end

    it "copies the input's value by default, without a content type" do
      render_inline(described_class.new("Copy", target_id: "npm-install"))

      expect(page).not_to have_selector("button[data-copy-to-clipboard-content-type]")
    end

    it "copies the inner HTML with content_type: :inner_html" do
      render_inline(described_class.new("Copy", target_id: "code", content_type: :inner_html))

      expect(page).to have_selector("button[data-copy-to-clipboard-content-type='innerHTML']")
    end

    it "copies the text content with content_type: :text_content" do
      render_inline(described_class.new("Copy", target_id: "code", content_type: :text_content))

      expect(page).to have_selector("button[data-copy-to-clipboard-content-type='textContent']")
    end

    it "rejects an unknown content type" do
      expect { described_class.new("Copy", target_id: "code", content_type: :html) }
        .to raise_error(Gustwave::Options::UnknownValueError)
    end

    it "decodes HTML entities with html_entities: true" do
      render_inline(described_class.new("Copy", target_id: "code", html_entities: true))

      expect(page).to have_selector("button[data-copy-to-clipboard-html-entities='true']")
    end

    it "omits the html entities attribute by default" do
      render_inline(described_class.new("Copy", target_id: "code"))

      expect(page).not_to have_selector("button[data-copy-to-clipboard-html-entities]")
    end

    it "merges a caller's data-controller with the controller" do
      render_inline(described_class.new("Copy", target_id: "npm-install", data: { controller: "analytics" }))

      expect(page).to have_selector("button[data-controller='analytics gustwave--clipboard']")
    end

    it "keeps a caller's other data attributes" do
      render_inline(described_class.new("Copy", target_id: "npm-install", data: { turbo: "false" }))

      expect(page).to have_selector("button[data-turbo='false'][data-copy-to-clipboard-target='npm-install']")
    end
  end

  describe "states" do
    it "shows the label in the default state" do
      render_inline(described_class.new("Copy", target_id: "npm-install"))

      expect(page).to have_selector("button > span[data-gustwave--clipboard-target='message']", text: "Copy")
      expect(page).not_to have_selector("button .sr-only")
    end

    it "hides the copied state with the hidden attribute" do
      render_inline(described_class.new("Copy", target_id: "npm-install"))

      expect(page).to have_selector("button > span[data-gustwave--clipboard-target='copiedMessage'][hidden]", text: "Copied!", visible: :all)
    end

    it "renders the copied label visibly when the default label is visible" do
      render_inline(described_class.new("Copy", target_id: "npm-install", copied_text: "Copied"))

      expect(page).to have_selector("button > span[data-gustwave--clipboard-target='copiedMessage']", text: "Copied", visible: :all)
      expect(page).not_to have_selector("button .sr-only", visible: :all)
    end

    it "keeps the copied label screen reader only when the default label is" do
      I18n.with_locale(:en) { render_inline(described_class.new(target_id: "api-key")) }

      expect(page).to have_selector("span[data-gustwave--clipboard-target='copiedMessage'] > span.sr-only", text: "Copied!", visible: :all)
    end

    it "takes the label from block content" do
      render_inline(described_class.new(target_id: "npm-install")) { "Copy link" }

      expect(page).to have_selector("button > span[data-gustwave--clipboard-target='message']", text: "Copy link")
      expect(page).not_to have_selector("button .sr-only")
    end

    it "prefers the text over block content" do
      render_inline(described_class.new("Copy", target_id: "npm-install")) { "Ignored" }

      expect(page).to have_selector("button", text: "Copy")
      expect(page).not_to have_text("Ignored")
    end

    it "labels an icon-only button with screen reader text" do
      I18n.with_locale(:en) { render_inline(described_class.new(target_id: "api-key")) }

      expect(page).to have_selector("button > span[data-gustwave--clipboard-target='message'] > span.sr-only", text: "Copy to clipboard")
    end

    it "localizes the default label" do
      I18n.with_locale(:de) { render_inline(described_class.new(target_id: "api-key")) }

      expect(page).to have_selector("span.sr-only", text: "In die Zwischenablage kopieren")
    end

    it "localizes the copied label" do
      I18n.with_locale(:de) { render_inline(described_class.new(target_id: "api-key")) }

      expect(page).to have_selector("span[data-gustwave--clipboard-target='copiedMessage']", text: "Kopiert!", visible: :all)
    end

    it "keeps the caller's copied_text over the default" do
      I18n.with_locale(:de) { render_inline(described_class.new(target_id: "api-key", copied_text: "Fertig")) }

      expect(page).to have_selector("span[data-gustwave--clipboard-target='copiedMessage']", text: "Fertig", visible: :all)
    end

    it "styles the state labels with message_options and copied_message_options" do
      render_inline(described_class.new("Copy", target_id: "npm-install",
                                                 message_options: { class: "font-bold" },
                                                 copied_message_options: { class: "text-green-700", id: "copied" }))

      expect(page).to have_selector("span.font-bold[data-gustwave--clipboard-target='message']", text: "Copy")
      expect(page).to have_selector("span#copied.text-green-700[data-gustwave--clipboard-target='copiedMessage']", visible: :all)
    end
  end

  describe "icons" do
    it "renders a clipboard icon by default for an icon-only button" do
      render_inline(described_class.new(target_id: "api-key"))

      expect(page).to have_selector("button > span[data-gustwave--clipboard-target='message'] > svg", visible: :all)
    end

    it "renders no icon for a button with a label" do
      render_inline(described_class.new("Copy", target_id: "npm-install"))

      expect(page).not_to have_selector("span[data-gustwave--clipboard-target='message'] > svg")
    end

    it "renders the icon set with with_icon beside the label" do
      render_inline(described_class.new("Copy", target_id: "npm-install")) do |clipboard|
        clipboard.with_icon(:clipboard_check)
      end

      expect(page).to have_selector("span[data-gustwave--clipboard-target='message'] > svg.shrink-0")
      expect(page).to have_selector("span[data-gustwave--clipboard-target='message']", text: "Copy")
    end

    it "renders a check icon in the copied state by default" do
      render_inline(described_class.new("Copy", target_id: "npm-install"))

      expect(page).to have_selector("span[data-gustwave--clipboard-target='copiedMessage'] > svg", visible: :all)
    end

    it "renders the copied icon set with with_copied_icon" do
      render_inline(described_class.new("Copy", target_id: "npm-install")) do |clipboard|
        clipboard.with_copied_icon(:check_circle, theme: :solid, class: "text-green-700")
      end

      expect(page).to have_selector("span[data-gustwave--clipboard-target='copiedMessage'] > svg.text-green-700", visible: :all)
    end

    it "hides the icons from screen readers" do
      render_inline(described_class.new(target_id: "api-key"))

      expect(page).to have_selector("svg[aria-hidden='true']", count: 2, visible: :all)
    end

    it "passes the icon's own options to the icon" do
      render_inline(described_class.new("Copy", target_id: "npm-install")) do |clipboard|
        clipboard.with_icon(:clipboard, class: "text-red-500")
      end

      expect(page).to have_selector("svg.text-red-500")
    end
  end

  describe "appearance" do
    it "renders the button of the given theme" do
      render_inline(described_class.new("Copy", target_id: "npm-install", theme: :inline))

      expect(page).to have_selector("button[data-copy-to-clipboard-target='npm-install']")
      expect(page).not_to have_selector("button.rounded-lg.bg-blue-700")
    end

    it "forwards the color and size to the button" do
      render_inline(described_class.new("Copy", target_id: "npm-install", color: :light, size: :xs))

      expect(page).to have_selector("button.bg-white.border-gray-300.text-xs")
    end

    it "forwards HTML attributes to the button" do
      render_inline(described_class.new("Copy", target_id: "npm-install", id: "copy-npm", class: "w-full"))

      expect(page).to have_selector("button#copy-npm.w-full[data-copy-to-clipboard-target='npm-install']")
    end
  end

  describe "tooltip" do
    it "does not render a tooltip by default" do
      render_inline(described_class.new("Copy", target_id: "npm-install"))

      expect(page).not_to have_selector("[role='tooltip']", visible: :all)
      expect(page).not_to have_selector("button[data-tooltip-target]")
    end

    it "renders the tooltip after the button" do
      render_inline(described_class.new("Copy", target_id: "npm-install")) { |clipboard| clipboard.with_tooltip }

      expect(page).to have_selector("button + div[role='tooltip']", visible: :all)
    end

    it "points the button at the tooltip with its trigger attributes" do
      render_inline(described_class.new("Copy", target_id: "npm-install")) { |clipboard| clipboard.with_tooltip }

      tooltip_id = page.find("[role='tooltip']", visible: :all)[:id]
      expect(page).to have_selector("button[data-tooltip-target='#{tooltip_id}'][data-tooltip-trigger='hover'][aria-describedby='#{tooltip_id}']")
    end

    it "points the controller at the tooltip" do
      render_inline(described_class.new("Copy", target_id: "npm-install")) { |clipboard| clipboard.with_tooltip }

      tooltip_id = page.find("[role='tooltip']", visible: :all)[:id]
      expect(page).to have_selector("button[data-gustwave--clipboard-tooltip-id-value='#{tooltip_id}']")
    end

    it "keeps the caller's own aria-describedby" do
      render_inline(described_class.new("Copy", target_id: "npm-install", aria: { describedby: "help" })) do |clipboard|
        clipboard.with_tooltip
      end

      tooltip_id = page.find("[role='tooltip']", visible: :all)[:id]
      expect(page).to have_selector("button[aria-describedby='help #{tooltip_id}']")
    end

    it "renders the default and copied tooltip texts, the copied one hidden" do
      I18n.with_locale(:en) do
        render_inline(described_class.new("Copy", target_id: "npm-install")) { |clipboard| clipboard.with_tooltip }
      end

      expect(page).to have_selector("[role='tooltip'] > span[data-gustwave--clipboard-target='message']", text: "Copy to clipboard", visible: :all)
      expect(page).to have_selector("[role='tooltip'] > span[data-gustwave--clipboard-target='copiedMessage'][hidden]", text: "Copied!", visible: :all)
    end

    it "renders the given tooltip texts" do
      render_inline(described_class.new("Copy", target_id: "npm-install")) do |clipboard|
        clipboard.with_tooltip("Copy link", copied_text: "Link copied")
      end

      expect(page).to have_selector("[role='tooltip'] > span[data-gustwave--clipboard-target='message']", text: "Copy link", visible: :all)
      expect(page).to have_selector("[role='tooltip'] > span[data-gustwave--clipboard-target='copiedMessage']", text: "Link copied", visible: :all)
    end

    it "passes the placement to the button" do
      render_inline(described_class.new("Copy", target_id: "npm-install")) do |clipboard|
        clipboard.with_tooltip(placement: :bottom)
      end

      expect(page).to have_selector("button[data-tooltip-placement='bottom']")
    end

    it "passes the trigger event to the button" do
      render_inline(described_class.new("Copy", target_id: "npm-install")) do |clipboard|
        clipboard.with_tooltip(trigger_event: :click)
      end

      expect(page).to have_selector("button[data-tooltip-trigger='click']")
    end

    it "passes the tooltip's color to the tooltip" do
      render_inline(described_class.new("Copy", target_id: "npm-install")) do |clipboard|
        clipboard.with_tooltip(color: :light)
      end

      expect(page).to have_selector("[role='tooltip'].bg-white", visible: :all)
      expect(page).to have_selector("button[data-tooltip-style='light']")
    end

    it "renders the icon-only button's tooltip" do
      render_inline(described_class.new(target_id: "api-key")) { |clipboard| clipboard.with_tooltip }

      expect(page).to have_selector("button[data-tooltip-target] > span[data-gustwave--clipboard-target='message'] > svg", visible: :all)
    end
  end

  describe "reset_after" do
    it "keeps the copied state with a reset delay of zero" do
      render_inline(described_class.new("Copy", target_id: "npm-install", reset_after: 0))

      expect(page).to have_selector("button[data-gustwave--clipboard-reset-after-value='0']")
    end
  end
end
