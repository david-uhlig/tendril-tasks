require "rails_helper"

# Captures full-page screenshots of the main pages and all ViewComponent
# previews to detect visual regressions, e.g. when upgrading TailwindCSS or
# Flowbite. Excluded from regular runs, see `spec/rails_helper.rb`.
#
# Usage:
#   VISUAL_LABEL=before bundle exec rspec spec/visual
#   # ...make changes...
#   VISUAL_LABEL=after bundle exec rspec spec/visual
#   bin/visual-diff before after
#
# Screenshots are written to `tmp/visual/<label>/`.
RSpec.describe "Visual snapshots", type: :system, js: true, visual: true do
  widths = { desktop: 1280, mobile: 390 }.freeze

  rich_text = <<~HTML
    <h1>Heading one</h1>
    <p>A paragraph with <strong>bold</strong>, <em>italic</em> and a <a href="#">link</a>.</p>
    <h2>Heading two</h2>
    <ul><li>First item</li><li>Second item<ul><li>Nested item</li></ul></li></ul>
    <ol><li>Numbered item</li><li>Another numbered item</li></ol>
    <blockquote>A quote that stands out.</blockquote>
    <pre>preformatted code block</pre>
    <h4>Heading four</h4>
    <p>A paragraph with <mark style="color: var(--highlight-3); background-color: var(--highlight-bg-3);">highlighted</mark> text.</p>
    <table><tbody><tr><th>Name</th><th>Value</th></tr><tr><td>Water</td><td>10 l</td></tr></tbody></table>
    <hr>
    <div>A paragraph stored by Trix.</div>
  HTML

  include ActiveSupport::Testing::TimeHelpers

  # Declared before the `let!` blocks, so that all records share the same timestamps.
  before { travel_to Time.zone.local(2026, 1, 15, 10, 0, 0) }

  let(:admin) do
    create(:user, :admin, name: "Ada Admin", username: "ada.admin", email: "ada@example.com",
                          uid: "visual-admin", avatar_url: "/icon.png")
  end
  let(:editor) do
    create(:user, :editor, name: "Eddie Editor", username: "eddie.editor", email: "eddie@example.com",
                           uid: "visual-editor", avatar_url: "/icon.svg")
  end
  let(:volunteer) do
    create(:user, name: "Vera Volunteer", username: "vera.volunteer", email: "vera@example.com",
                  uid: "visual-volunteer", avatar_url: "/icon.png")
  end
  let(:applicant) do
    create(:user, name: "Arne Applicant", username: "arne.applicant", email: "arne@example.com",
                  uid: "visual-applicant", avatar_url: "/icon.svg")
  end

  let!(:project) do
    create(:project, published_at: 1.day.ago, title: "Community garden", description: rich_text,
                                 coordinators: [ admin, editor ])
  end
  let!(:draft_project) do
    create(:project, :not_published, title: "Draft project", coordinators: [ editor ])
  end
  let!(:task) do
    create(:task, published_at: 1.day.ago, project:, title: "Water the plants", description: rich_text,
                              coordinators: [ admin, editor ])
  end
  let!(:other_task) do
    create(:task, published_at: 2.days.ago, project:, title: "Build a compost bin", coordinators: [ editor ])
  end
  let!(:draft_task) do
    create(:task, :not_published, project: draft_project, title: "Draft task", coordinators: [ editor ])
  end

  before do
    %w[ imprint privacy-policy terms-of-service ].each { |slug| create(:page, slug:, content: rich_text) }
    create(:task_application, task:, user: applicant, comment: "I would love to help!", status: :under_review)
    create(:task_application, task: other_task, user: volunteer, comment: "Count me in.")
  end

  def label
    ENV.fetch("VISUAL_LABEL")
  end

  def output_dir
    Rails.root.join("tmp/visual", label).tap(&:mkpath)
  end

  # Disables animations, transitions and the blinking caret so that
  # screenshots are deterministic.
  def freeze_page
    page.execute_script(<<~JS)
      const style = document.createElement("style");
      style.textContent = `*, *::before, *::after {
        animation: none !important; transition: none !important; caret-color: transparent !important;
      }
      html { scrollbar-width: none; }`;
      document.head.appendChild(style);
    JS
  end

  def snapshot(name, width:)
    freeze_page
    page.driver.browser.manage.window.resize_to(width, 800)
    # The window size includes the browser chrome, so add its height to fit the whole page.
    chrome_height = page.evaluate_script("window.outerHeight - window.innerHeight")
    height = page.evaluate_script("document.documentElement.scrollHeight")
    page.driver.browser.manage.window.resize_to(width, [ height, 800 ].max + chrome_height)
    page.execute_script("window.scrollTo(0, 0)")
    page.save_screenshot(output_dir.join("#{name}.png").to_s)
  end

  # name => [ user, path, interaction ]
  pages = {
    "home" => [ nil, -> { root_path } ],
    "sign_in" => [ nil, -> { new_user_session_path } ],
    "legal_imprint" => [ nil, -> { legal_path("imprint") } ],
    "home_signed_in" => [ :volunteer, -> { root_path } ],
    "dashboard_volunteer" => [ :volunteer, -> { dashboard_path } ],
    "dashboard_admin" => [ :admin, -> { dashboard_path } ],
    "profile" => [ :volunteer, -> { profile_path } ],
    "profile_delete_modal" => [ :volunteer, -> { profile_path }, -> { click_button "Mein Konto löschen" } ],
    "avatar_dropdown" => [ :admin, -> { root_path },
                           -> { find("[data-dropdown-toggle='avatar-dropdown-menu']").click } ],
    "projects_index" => [ :admin, -> { projects_path } ],
    "project_show" => [ :admin, -> { project_path(project) } ],
    "project_new" => [ :admin, -> { new_project_path } ],
    "project_edit" => [ :admin, -> { edit_project_path(project) } ],
    "project_tasks" => [ :admin, -> { project_tasks_path(project) } ],
    "tasks_index" => [ :admin, -> { tasks_path } ],
    "task_show_volunteer" => [ :volunteer, -> { task_path(task) } ],
    "task_show_applied" => [ :volunteer, -> { task_path(other_task) } ],
    "task_show_coordinator" => [ :admin, -> { task_path(task) } ],
    "task_application_status_dropdown" => [ :admin, -> { task_path(task) },
                                            -> { first("[data-dropdown-toggle^='dropdown-status-info-']").click } ],
    "task_visibility_popover" => [ :admin, -> { task_path(task) },
                                   -> { first("[data-popover-target]").hover && find("[data-popover]", visible: true) } ],
    "task_new" => [ :admin, -> { new_task_path } ],
    "task_edit" => [ :admin, -> { edit_task_path(task) } ],
    "admin_dashboard" => [ :admin, -> { admin_root_path } ],
    "admin_brand" => [ :admin, -> { edit_admin_brand_path } ],
    "admin_footer" => [ :admin, -> { edit_admin_footer_path } ],
    "admin_legal" => [ :admin, -> { admin_legal_index_path } ],
    "admin_user_roles" => [ :admin, -> { admin_users_roles_path } ],
    "legal_edit" => [ :admin, -> { edit_legal_path("imprint") } ]
  }

  pages.each do |name, (user, path, interaction)|
    widths.each do |device, width|
      it "#{name} (#{device})" do
        login_as(send(user), scope: :user) if user
        page.driver.browser.manage.window.resize_to(width, 800)
        visit instance_exec(&path)
        instance_exec(&interaction) if interaction
        snapshot("#{name}--#{device}", width:)
      end
    end
  end

  it "mobile navigation (expanded)" do
    login_as(admin, scope: :user)
    page.driver.browser.manage.window.resize_to(widths[:mobile], 800)
    visit root_path
    find("[data-collapse-toggle='navbar-cta']").click
    snapshot("mobile_navigation_expanded--mobile", width: widths[:mobile])
  end

  ViewComponent::Preview.all.each do |preview|
    preview.examples.each do |example|
      it "preview #{preview.preview_name}/#{example}" do
        visit "/rails/view_components/#{preview.preview_name}/#{example}"
        snapshot("preview--#{preview.preview_name.tr('/', '-')}--#{example}", width: widths[:desktop])
      end
    end
  end
end
