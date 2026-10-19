require "rails_helper"

RSpec.describe TendrilTasks::ContactsPill, type: :component do
  let(:coordinators) { build_list(:user, 2) }

  it "renders a button that toggles the modal" do
    render_inline(described_class.new(coordinators, modal_id: "contacts"))

    expect(rendered_content).to have_selector("button[type='button'][data-modal-target='contacts'][data-modal-toggle='contacts']")
  end

  it "lists the label and the coordinators' names" do
    render_inline(described_class.new(coordinators, modal_id: "contacts"))

    expect(rendered_content).to have_selector("button > span", text: "Kontakte")
    coordinators.each do |coordinator|
      expect(rendered_content).to have_selector("button span.truncate", text: coordinator.name)
    end
  end
end
