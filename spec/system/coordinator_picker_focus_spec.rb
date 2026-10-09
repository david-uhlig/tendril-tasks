require "rails_helper"

RSpec.describe "Coordinator picker focus", type: :system, js: true, optional: true do
  let(:editor) { create(:user, :editor) }

  before do
    login_as(editor)
    visit new_task_path
  end

  it "focuses the search field when the picker opens" do
    click_button "edit-coordinator-assignment"

    expect(page).to have_selector("##{Form::CoordinatorPicker::ModalComponent::ID} input#search:focus")
  end
end
