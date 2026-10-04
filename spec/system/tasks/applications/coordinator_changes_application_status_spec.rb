require "rails_helper"

RSpec.describe "Coordinator changes application status", type: :system, js: true do
  let(:admin) { create(:user, :admin) }
  let(:task) { create(:task, :published, :with_published_project) }
  let!(:application) { create(:task_application, task: task) }
  let(:trigger_selector) { "#dropdown-status-button-#{application.user.id}" }
  let(:menu_selector) { "#dropdown-status-info-#{application.user.id}" }
  let(:statuses) { TaskApplication::COORDINATOR_STATUSES }

  def status_label(status)
    I18n.t("activerecord.attributes.task_application.status.#{status}")
  end

  def focused_option
    find("#{menu_selector} button:focus")
  end

  before do
    login_as(admin)
    visit task_path(task)
  end

  context "with the keyboard", optional: true do
    before do
      find(trigger_selector).send_keys(:enter)
    end

    it "opens the menu with the current status focused" do
      expect(page).to have_selector(menu_selector, visible: true)
      expect(page).to have_selector("#{trigger_selector}[aria-expanded='true']")
      expect(focused_option).to have_text(status_label(:received))
    end

    it "moves between the options with the arrow keys without changing the status" do
      focused_option.send_keys(:down, :down)
      expect(page).to have_selector("#{menu_selector} button:focus", text: status_label(statuses[2]))

      focused_option.send_keys(:up)
      expect(page).to have_selector("#{menu_selector} button:focus", text: status_label(statuses[1]))

      focused_option.send_keys(:end)
      expect(page).to have_selector("#{menu_selector} button:focus", text: status_label(statuses.last))

      expect(application.reload.status).to eq("received")
    end

    it "closes the menu with Escape and returns focus to the trigger" do
      focused_option.send_keys(:escape)

      expect(page).to have_no_selector(menu_selector, visible: true)
      expect(page).to have_selector("#{trigger_selector}[aria-expanded='false']:focus")
    end

    it "closes the menu when tabbing out of it" do
      focused_option.send_keys([ :shift, :tab ], [ :shift, :tab ])

      expect(page).to have_no_selector(menu_selector, visible: true)
    end

    it "changes the status with Enter and returns focus to the trigger" do
      focused_option.send_keys(:down)
      expect(page).to have_selector("#{menu_selector} button:focus", text: status_label(statuses[1]))
      focused_option.send_keys(:enter)

      expect(page).to have_selector(trigger_selector, text: status_label(statuses[1]))
      expect(page).to have_selector("#{trigger_selector}:focus")
      expect(page).to have_no_selector(menu_selector, visible: true)
      expect(application.reload.status).to eq(statuses[1])
    end

    it "opens the menu again after changing the status" do
      focused_option.send_keys(:down, :enter)
      expect(page).to have_selector("#{trigger_selector}:focus", text: status_label(statuses[1]))

      find(trigger_selector).send_keys(:enter)

      expect(page).to have_selector(menu_selector, visible: true)
      expect(focused_option).to have_text(status_label(statuses[1]))
    end
  end

  context "with the mouse" do
    before do
      find(trigger_selector).click
    end

    it "changes the status" do
      within(menu_selector) { click_button status_label(:accepted) }

      expect(page).to have_selector(trigger_selector, text: status_label(:accepted))
      expect(application.reload.status).to eq("accepted")
    end

    it "closes the menu with Escape", optional: true do
      expect(page).to have_selector(menu_selector, visible: true)
      find(trigger_selector).send_keys(:escape)

      expect(page).to have_no_selector(menu_selector, visible: true)
    end
  end
end
