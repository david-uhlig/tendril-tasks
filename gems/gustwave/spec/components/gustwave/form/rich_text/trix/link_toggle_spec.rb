# frozen_string_literal: true

require "rails_helper"

RSpec.describe Gustwave::Form::RichText::Trix::LinkToggle, type: :component do
  def button
    page.find("button[data-trix-attribute]")
  end

  def dialog
    page.find("[data-trix-dialog]", visible: :all)
  end

  it "renders the href button with its Trix key" do
    render_inline(described_class.new(nil))

    expect(button["data-trix-attribute"]).to eq("href")
    expect(button["data-trix-key"]).to eq("k")
  end

  it "renders the href button as the trigger of the dialog" do
    render_inline(described_class.new(nil))

    expect(button["aria-controls"]).to eq(dialog["id"])
  end

  it "renders the dialog for the href attribute" do
    render_inline(described_class.new(nil))

    expect(dialog["data-trix-dialog-attribute"]).to eq("href")
  end

  it "renders a URL input in the dialog" do
    render_inline(described_class.new(nil))

    expect(page).to have_css("[data-trix-dialog] input[type='url'][data-trix-input]", visible: :all)
  end

  it "renders a button in the dialog that sets the href" do
    render_inline(described_class.new(nil))

    expect(page).to have_css("[data-trix-dialog] button[data-trix-method='setAttribute']", visible: :all)
  end

  it "renders an enabled button by default" do
    render_inline(described_class.new(nil))

    expect(button).not_to be_disabled
  end

  context "when disabled" do
    before do
      render_inline(described_class.new(nil, disabled: true))
    end

    it "renders a disabled button" do
      expect(page).to have_css("button[disabled]")
    end

    it "does not render the Trix attributes of the button" do
      expect(page).to have_no_css("button[data-trix-attribute]")
    end
  end
end
