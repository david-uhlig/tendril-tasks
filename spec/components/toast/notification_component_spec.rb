require "rails_helper"

RSpec.describe Toast::NotificationComponent, type: :component do
  it "shows the message in an alert" do
    render_inline(described_class.new("Gespeichert"))

    expect(page).to have_css("[role='alert']", text: "Gespeichert")
  end

  it "shows a success toast by default" do
    render_inline(described_class.new("Gespeichert"))

    expect(page).to have_css("[role='alert'] span.sr-only", text: "Erfolg")
  end

  it "shows a success toast for the success type" do
    render_inline(described_class.new("Gespeichert", type: :success))

    expect(page).to have_css("[role='alert'] span.sr-only", text: "Erfolg")
  end

  context "with a timed out session flash from Devise" do
    before do
      render_inline(described_class.new("Sitzung abgelaufen", type: :timedout))
    end

    it "shows the message in an alert" do
      expect(page).to have_css("[role='alert']", text: "Sitzung abgelaufen")
    end

    it "shows a warning toast instead of a success toast" do
      expect(page).to have_css("[role='alert'] span.sr-only", text: "Warnung")
      expect(page).to have_no_css("[role='alert'] span.sr-only", text: "Erfolg")
    end
  end
end
