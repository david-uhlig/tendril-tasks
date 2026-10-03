require "rails_helper"

RSpec.describe TendrilTasks::ContactsPill, type: :component do
  let(:coordinators) { build_list(:user, 2) }

  it "renders a button that toggles the modal" do
    render_inline(described_class.new(coordinators, modal_id: "contacts"))

    expect(rendered_content).to have_selector("button[type='button'][data-modal-target='contacts'][data-modal-toggle='contacts'].rounded-full")
  end

  it "lists the label and the coordinators' names" do
    render_inline(described_class.new(coordinators, modal_id: "contacts"))

    expect(rendered_content).to have_selector("button > span.bg-blue-600", text: "Kontakte")
    coordinators.each do |coordinator|
      expect(rendered_content).to have_selector("button span.truncate", text: coordinator.name)
    end
    expect(rendered_content).to have_selector("button > svg")
  end

  it "merges custom classes" do
    render_inline(described_class.new(coordinators, modal_id: "contacts", class: "pe-2 my-4"))

    expect(rendered_content).to have_selector("button.pe-2.my-4:not(.pe-4)")
  end
end
