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
      shell.with_heading "Title"
      "<p>Body</p>".html_safe
    end

    expect(rendered_content).to have_selector("h3", text: "Title", visible: :all)
    expect(rendered_content).to have_selector("div:has(> h3) + p", text: "Body", visible: :all)
  end

  it "traps the focus within the modal" do
    render_inline(described_class.new("dialog"))

    expect(rendered_content).to have_selector("section[data-controller='gustwave--focus-trap']", visible: :all)
  end

  it "merges data attributes with the backdrop and the focus trap" do
    render_inline(described_class.new("dialog", data: { controller: "cooldown", "cooldown-seconds-value": 3 }))

    expect(rendered_content).to have_selector("section[data-modal-backdrop='static'][data-controller='gustwave--focus-trap cooldown'][data-cooldown-seconds-value='3']", visible: :all)
  end
end
