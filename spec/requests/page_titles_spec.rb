require "rails_helper"

RSpec.describe "Page titles", type: :request do
  let(:admin) { create(:user, :admin) }
  let(:project) { create(:project, :published, title: "Gardening") }
  let(:task) { create(:task, :published, project:, title: "Water the plants") }

  before { Site.create!(name: "Acme", tagline: "for everyone") }

  def title = Nokogiri::HTML(response.body).at_css("title").text

  it "shows the site name and tagline on the home page" do
    get root_path

    expect(title).to eq("Acme - for everyone")
  end

  it "shows the title of the sign in page" do
    get new_user_session_path

    expect(title).to eq("#{I18n.t("devise.sessions.new.page_title")} - Acme")
  end

  context "when signed in" do
    before { login_as(admin) }

    {
      "dashboard" => [ -> { dashboard_path }, -> { I18n.t("breadcrumbs.dashboard") } ],
      "profile" => [ -> { profile_path }, -> { I18n.t("users.profile.edit.title") } ],
      "initiatives" => [ -> { projects_path }, -> { Project.model_name.human(count: 2) } ],
      "new initiative" => [ -> { new_project_path }, -> { I18n.t("projects.new.title") } ],
      "tasks" => [ -> { tasks_path }, -> { Task.model_name.human(count: 2) } ],
      "new task" => [ -> { new_task_path }, -> { I18n.t("tasks.new.title") } ],
      "administration" => [ -> { admin_root_path }, -> { I18n.t("admin.title") } ],
      "site" => [ -> { edit_admin_site_path }, -> { I18n.t("admin.site.title") } ],
      "footer" => [ -> { edit_admin_footer_path }, -> { I18n.t("admin.footer.title") } ],
      "legal documents" => [ -> { admin_legal_index_path }, -> { I18n.t("admin.legal.title") } ],
      "roles" => [ -> { admin_users_roles_path }, -> { I18n.t("admin.users.roles.title") } ]
    }.each do |page, (path, page_title)|
      it "shows the title of the #{page} page" do
        get instance_exec(&path)

        expect(title).to eq("#{instance_exec(&page_title)} - Acme")
      end
    end

    it "shows the title of an initiative" do
      get project_path(project)

      expect(title).to eq("Gardening - Acme")
    end

    it "shows the title of the initiative that filters the tasks" do
      task

      get tasks_path(project_id: project.id)

      expect(title).to eq("#{I18n.t("tasks.index.page_title_for_initiative", initiative: "Gardening")} - Acme")
    end

    it "shows the title of a task" do
      get task_path(task)

      expect(title).to eq("Water the plants - Acme")
    end

    it "shows the saved title of the initiative being edited" do
      get edit_project_path(project)

      expect(title).to eq("#{I18n.t("forms.headings.edit", thing: "Gardening")} - Acme")
    end

    it "keeps the saved title of the initiative when it can't be saved" do
      patch project_path(project), params: { project_form: { title: "" } }

      expect(response).to have_http_status(:unprocessable_content)
      expect(title).to eq("#{I18n.t("forms.headings.edit", thing: "Gardening")} - Acme")
    end

    it "shows the saved title of the task being edited" do
      get edit_task_path(task)

      expect(title).to eq("#{I18n.t("forms.headings.edit", thing: "Water the plants")} - Acme")
    end

    it "shows the title of a legal page" do
      create(:page, slug: "imprint")

      get legal_path("imprint")

      expect(title).to eq("#{I18n.t("pages.imprint.title")} - Acme")
    end

    it "shows the title and heading of a legal page being edited" do
      create(:page, slug: "imprint")

      get edit_legal_path("imprint")

      heading = I18n.t("forms.headings.edit", thing: I18n.t("pages.imprint.title"))
      expect(title).to eq("#{heading} - Acme")
      expect(Nokogiri::HTML(response.body).at_css("h1").text.strip).to eq(heading)
    end

    it "shows the title and heading of a legal page being created" do
      get edit_legal_path("imprint")

      heading = I18n.t("forms.headings.new", thing: I18n.t("pages.imprint.title"))
      expect(title).to eq("#{heading} - Acme")
      expect(Nokogiri::HTML(response.body).at_css("h1").text.strip).to eq(heading)
    end
  end

  it "escapes the title of a page once" do
    login_as(admin)
    project.update!(title: "Cats & Mice")

    get project_path(project)

    expect(response.body).to include("<title>Cats &amp; Mice - Acme</title>")
  end
end
