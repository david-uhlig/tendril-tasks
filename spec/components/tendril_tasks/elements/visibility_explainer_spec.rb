require "rails_helper"

RSpec.describe TendrilTasks::Elements::VisibilityExplainer, type: :component do
  let(:user) { create(:user) }
  let(:task) { create(:task, :published, :with_published_project, coordinators: [ user ]) }

  before do
    allow(vc_test_controller).to receive(:current_user).and_return(user)
  end

  it "renders the explanation as a popover with the headline" do
    render_inline(described_class.new(task))

    expect(page).to have_selector("div[data-popover][role='tooltip'].w-72", text: "Für alle sichtbar")
  end

  it "points the icon trigger at the popover and describes it" do
    render_inline(described_class.new(task))

    popover_id = page.find("div[data-popover]")[:id]
    expect(popover_id).to be_present
    expect(page).to have_selector("[data-popover-target='#{popover_id}'][aria-describedby~='#{popover_id}']")
  end

  it "gives each explainer its own popover id" do
    render_inline(described_class.new(task))
    first_id = page.find("div[data-popover]")[:id]

    render_inline(described_class.new(task))
    second_id = page.find("div[data-popover]")[:id]

    expect(first_id).not_to eq(second_id)
  end

  it "renders nothing when the user cannot coordinate the element" do
    other_task = create(:task, :published, :with_published_project)

    render_inline(described_class.new(other_task))

    expect(rendered_content).to be_blank
  end
end
