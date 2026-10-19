require "rails_helper"

RSpec.describe TendrilTasks::Tasks::Application, type: :component do
  let(:viewer) { create(:user) }
  let(:applicant) { create(:user, name: "Erika Musterfrau") }
  let(:application) do
    create(:task_application, user: applicant, comment: "I can do it on Mondays")
  end

  before do
    as(viewer)
  end

  it "shows the applicant's name and the application date" do
    render_inline(described_class.new(application))

    expect(page).to have_text("Erika Musterfrau")
    expect(page).to have_text(I18n.t("task_application.applied_on_date",
                                     date: I18n.l(application.created_at, format: :long)))
  end

  it "shows the applicant's comment" do
    render_inline(described_class.new(application))

    expect(page).to have_text("I can do it on Mondays")
  end

  context "when the application is not withdrawn" do
    it "shows no withdrawal date" do
      render_inline(described_class.new(application))

      expect(page).to have_css("time", count: 1)
      expect(page).to have_no_text(I18n.t("task_application.withdrawn_on_date", date: ""))
    end
  end

  context "when the application is withdrawn" do
    let(:application) do
      create(:task_application, :withdrawn, user: applicant, withdrawn_at: 3.days.ago)
    end

    it "shows the withdrawal date" do
      render_inline(described_class.new(application))

      expect(page).to have_css("time[datetime='#{application.withdrawn_at.iso8601}']",
                               text: I18n.t("task_application.withdrawn_on_date",
                                            date: I18n.l(application.withdrawn_at, format: :long)))
    end
  end

  context "when the application was created within the last week" do
    let(:application) { create(:task_application, user: applicant, created_at: 2.days.ago) }

    it "shows the new badge" do
      render_inline(described_class.new(application))

      expect(page).to have_text(I18n.t("badges.new"))
    end
  end

  context "when the application was created longer ago than a week" do
    let(:application) { create(:task_application, user: applicant, created_at: 2.weeks.ago) }

    it "shows no new badge" do
      render_inline(described_class.new(application))

      expect(page).to have_no_text(I18n.t("badges.new"))
    end
  end
end
