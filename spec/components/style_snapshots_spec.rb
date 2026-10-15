require "rails_helper"
require "gustwave/test/style_snapshots"

# Snapshots of the markup the app's styled components render, as a safety net
# while Gustwave's styling concerns are replaced. Regenerate with
# UPDATE_STYLE_SNAPSHOTS=1 and review the fixture diff.
RSpec.describe "Style snapshots", type: :component do
  extend Gustwave::Test::StyleSnapshots
  self.style_snapshot_dir = Rails.root.join("spec/fixtures/style_snapshots")

  custom_class = [ nil, "px-0 bg-black text-white" ].freeze

  style_snapshot "TendrilTasks::Heading" do
    group :heading, content: "Title", tag: %i[h1 h3], scheme: [ nil, :none, :level1, :level2, :level3, :level4, :level5, :level6 ],
          responsive: [ true, false ], hyphenated: [ true, false ] do |**args|
      TendrilTasks::Heading.new(**args)
    end
    group :custom, content: "Title", tag: :h2, class: custom_class do |**args|
      TendrilTasks::Heading.new(**args)
    end
  end

  style_snapshot "TendrilTasks::Paragraph" do
    group :paragraph, content: "Text", size: [ nil, :sm, :md, :lg ], hyphenated: [ true, false ], class: custom_class do |size: nil, **args|
      TendrilTasks::Paragraph.new(**args, **{ size: }.compact)
    end
  end

  style_snapshot "TendrilTasks::Content" do
    group :content, content: "Text", width: [ nil, :full, :large ], class: custom_class do |width: nil, **args|
      TendrilTasks::Content.new(**args, **{ width: }.compact)
    end
  end

  style_snapshot "TendrilTasks::Logo" do
    group :logo, size: %i[sm lg], class: custom_class do |**args|
      TendrilTasks::Logo.new(**args)
    end
  end

  style_snapshot "TendrilTasks::NewItemBadge" do
    group :badge, scheme: %i[green red], size: %i[xs lg], pill: [ true, false ], border: [ true, false ],
          class: custom_class do |**args|
      TendrilTasks::NewItemBadge.new("New", **args)
    end
  end

  style_snapshot "TendrilTasks::ButtonGrid" do
    group :grid, orientation: %i[responsive vertical horizontal], buttons: [ 1, 2, 3, 4 ],
          grid_options: [ {}, { class: "gap-0" } ] do |buttons:, **args|
      TendrilTasks::ButtonGrid.new(size: :lg, **args).tap do |grid|
        buttons.times { |i| grid.button(scheme: :alternative, class: "w-full").with_content("Button #{i}") }
      end
    end
  end

  style_snapshot "TendrilTasks::ListRow" do
    row = ->(r) { r.leading { "Avatar" } && r.title("Ada", class: "font-bold") }
    group :row, content: "Actions", slots: row, class: custom_class do |**args|
      TendrilTasks::ListRow.new(**args)
    end
  end

  style_snapshot "TendrilTasks::ContactsPill" do
    group :pill, class: custom_class do |**args|
      TendrilTasks::ContactsPill.new(build_list(:user, 2), modal_id: "contacts", **args)
    end
  end

  style_snapshot "TendrilTasks::Admin::Card" do
    card = lambda do |c|
      c.heading "Users"
      c.badge "New", icon: :check
      c.paragraph { "Text" }
      c.button(href: "/users") { "Open" }
    end
    group :card, slots: card do
      TendrilTasks::Admin::Card.new
    end
  end

  style_snapshot "TendrilTasks::Dashboard::Application" do
    group :application, task: %i[published not_published] do |task:|
      created_at = Time.zone.local(2026, 1, 1, 12)
      application = create(:task_application, task: create(:task, task, created_at:), created_at:, updated_at: created_at)
      TendrilTasks::Dashboard::Application.new(application)
    end
  end

  style_snapshot "TendrilTasks::Elements::VisibilityExplainer" do
    group :element, element: [ %i[task published with_published_project], %i[task not_published with_unpublished_project],
                               %i[project published with_published_tasks], %i[project not_published with_unpublished_tasks] ] do |element:|
      TendrilTasks::Elements::VisibilityExplainer.new(create(*element)).tap do |explainer|
        allow(explainer).to receive(:can?).and_return(true)
      end
    end
  end

  style_snapshot "TendrilTasks::Navigation::AvatarDropdownMenu" do
    # Users without an uploaded avatar: an ActiveStorage URL is signed with
    # secret_key_base and embeds the blob id, so it differs between machines.
    group :menu, user: [ [], %i[admin] ] do |user:|
      as(create(:user, *user))
      TendrilTasks::Navigation::AvatarDropdownMenu.new
    end
  end

  style_snapshot "Form::TextFieldComponent" do
    group :field, label: [ nil, "Title" ], class: custom_class do |label:, **args|
      form = ActionView::Helpers::FormBuilder.new(:task, Task.new, vc_test_controller.view_context, {})
      Form::TextFieldComponent.new(form, :title, label, **args)
    end
  end

  style_snapshot "Form::FileFieldComponent" do
    group :field, label: [ nil, "Avatar" ], class: custom_class do |label:, **args|
      form = ActionView::Helpers::FormBuilder.new(:user, User.new, vc_test_controller.view_context, {})
      Form::FileFieldComponent.new(form, :avatar, label, **args)
    end
  end
end
