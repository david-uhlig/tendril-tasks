require "rails_helper"

RSpec.describe Form::CoordinatorPicker::ModalComponent, type: :component do
  let(:assigned_coordinator) { create(:user) }
  let(:suggested_coordinator) { create(:user) }
  let(:other_suggested_coordinator) { create(:user) }

  let(:component) do
    described_class.new(assigned: [ assigned_coordinator ],
                        suggestions: [ suggested_coordinator, other_suggested_coordinator ])
  end

  it "names every coordinator checkbox coordinator_ids[]" do
    render_inline(component)

    expect(page).to have_css("input[type='checkbox'][name='coordinator_ids[]']", count: 3, visible: :all)
  end

  it "checks the assigned coordinators" do
    render_inline(component)

    expect(page).to have_css(
      "ul#coordinators input[name='coordinator_ids[]'][value='#{assigned_coordinator.id}'][checked]",
      visible: :all
    )
  end

  it "leaves the suggested coordinators unchecked" do
    render_inline(component)

    expect(page).to have_css("ul#candidates input[name='coordinator_ids[]'][value='#{suggested_coordinator.id}']", visible: :all)
    expect(page).to have_no_css("ul#candidates input[name='coordinator_ids[]'][checked]", visible: :all)
  end

  it "lists the suggested coordinators by name" do
    render_inline(component)

    expect(page).to have_text(suggested_coordinator.name)
    expect(page).to have_text(other_suggested_coordinator.name)
  end

  it "submits the form to the coordinator searches" do
    render_inline(component)

    expect(page).to have_css("form[action='/coordinators/searches'][method='post']")
  end

  it "hides the modal when the selection is applied" do
    render_inline(component)

    expect(page).to have_css("button[type='submit'][data-modal-hide='#{described_class::ID}']")
  end
end
