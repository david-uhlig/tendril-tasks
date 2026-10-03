require "rails_helper"

RSpec.describe Modal::ShellComponent, type: :component do
  it "renders a hidden modal with a static backdrop" do
    render_inline(described_class.new("dialog"))

    expect(rendered_content).to have_selector("section#dialog.hidden.fixed[tabindex='-1'][aria-hidden='true'][data-modal-backdrop='static']", visible: :all)
  end

  it "renders a close button for the modal" do
    render_inline(described_class.new("dialog"))

    expect(rendered_content).to have_selector("button[type='button'][data-modal-hide='dialog'] span.sr-only", text: "Schließen", visible: :all)
  end

  it "renders the heading and the content below the header" do
    render_inline(described_class.new("dialog")) do |shell|
      shell.heading "Title"
      "<p>Body</p>".html_safe
    end

    expect(rendered_content).to have_selector("h3.text-xl.font-semibold", text: "Title", visible: :all)
    expect(rendered_content).to have_selector("div:has(> h3) + p", text: "Body", visible: :all)
  end

  it "merges custom classes into the heading" do
    render_inline(described_class.new("dialog")) do |shell|
      shell.heading "Title", class: "text-lg"
    end

    expect(rendered_content).to have_selector("h3.text-lg.font-semibold:not(.text-xl)", text: "Title", visible: :all)
  end

  it "merges data attributes with the backdrop" do
    render_inline(described_class.new("dialog", data: { controller: "cooldown" }))

    expect(rendered_content).to have_selector("section[data-modal-backdrop='static'][data-controller='cooldown']", visible: :all)
  end
end
