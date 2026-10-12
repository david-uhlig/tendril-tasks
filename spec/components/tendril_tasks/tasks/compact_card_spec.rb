require "rails_helper"

RSpec.describe TendrilTasks::Tasks::CompactCard, type: :component do
  let(:user) { create(:user) }
  let(:coordinators) { create_list(:user, 2) }
  let(:task) do
    create(:task, :published, :with_published_project,
           title: "Water the plants",
           coordinators: coordinators)
  end

  before do
    allow(vc_test_controller).to receive(:current_user).and_return(user)
  end

  it "links the title to the task" do
    render_inline(described_class.new(task))

    expect(page).to have_link("Water the plants", href: "/tasks/#{task.id}")
  end

  it "shows the initiative and that the task is new" do
    render_inline(described_class.new(task))

    expect(page).to have_text(task.project.title)
    expect(page).to have_text("Neu")
  end

  describe "contact people" do
    it "shows them in a full width pill that opens the list of contact people" do
      render_inline(described_class.new(task))

      modal_id = "task-compact-card-contacts-#{task.id}"
      expect(page).to have_selector("button.w-full.rounded-full[data-modal-toggle='#{modal_id}']", text: "Hilf John und John")
    end

    def contact_line(*names)
      task.coordinators = names.map { |name| create(:user, name: name) }
      render_inline(described_class.new(task))
      page.find("span", text: /\AHilf /).text
    end

    it "asks to help the only contact person by first name" do
      expect(contact_line("Pete Miller")).to eq("Hilf Pete")
    end

    it "asks to help two contact people by first name" do
      expect(contact_line("Pete Miller", "Igor Novak")).to eq("Hilf Pete und Igor")
    end

    it "names two contact people and counts the rest" do
      expect(contact_line("Pete Miller", "Igor Novak", "Ann Lee", "Bo Kim"))
        .to eq("Hilf Pete, Igor und 2 weiteren")
    end

    it "falls back to the username when the name is blank" do
      user = create(:user, username: "pete")
      user.update_column(:name, "")
      task.coordinators = [ user ]

      render_inline(described_class.new(task))

      expect(page).to have_text("Hilf pete")
    end
  end

  it "has a single button to express interest" do
    render_inline(described_class.new(task))

    expect(page).to have_link("Jetzt melden!", href: "/tasks/#{task.id}#apply-now")
    expect(page).to have_no_link("Mehr erfahren")
  end

  it "shows that the user applied to the task" do
    create(:task_application, task: task, user: user)

    render_inline(described_class.new(task))

    expect(page).to have_link("Angemeldet!", href: "/tasks/#{task.id}#apply-now")
  end
end
