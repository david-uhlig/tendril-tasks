require "rails_helper"

# The read rules in Ability must list exactly the records that the
# `publicly_visible` scopes list, for every role that reads through them.
RSpec.describe "Ability visibility", type: :model do
  include ActiveSupport::Testing::TimeHelpers

  subject(:ability) { Ability.new(user) }

  # Frozen so that the ability, the scopes and the records share one instant.
  before { freeze_time }

  let!(:published_project) { create(:project, published_at: 1.day.ago) }
  let!(:unpublished_project) { create(:project, :not_published) }
  let!(:future_project) { create(:project, published_at: 1.day.from_now) }
  let!(:published_now_project) { create(:project, published_at: Time.zone.now) }
  let!(:project_without_published_tasks) { create(:project, published_at: 1.day.ago) }

  let!(:published_task) { create(:task, published_at: 1.day.ago, project: published_project) }
  let!(:second_published_task) { create(:task, published_at: 2.days.ago, project: published_project) }
  let!(:unpublished_task) { create(:task, :not_published, project: published_project) }
  let!(:future_task) { create(:task, published_at: 1.day.from_now, project: published_project) }
  let!(:published_now_task) { create(:task, published_at: Time.zone.now, project: published_project) }
  let!(:task_in_unpublished_project) { create(:task, published_at: 1.day.ago, project: unpublished_project) }
  let!(:task_in_future_project) { create(:task, published_at: 1.day.ago, project: future_project) }
  let!(:task_in_published_now_project) { create(:task, published_at: 1.day.ago, project: published_now_project) }
  let!(:unpublished_task_in_unpublished_project) { create(:task, :not_published, project: unpublished_project) }
  let!(:unpublished_task_without_published_tasks) do
    create(:task, :not_published, project: project_without_published_tasks)
  end

  def ids_of(records)
    records.map(&:id).sort
  end

  # Visitors are not given the publicly visible records: the listings and the
  # project and task pages redirect them to the login page. The ability grants
  # them no read access, so they read nothing even where the scopes would list
  # published records.
  context "when visitor" do
    let(:user) { nil }

    it "reads no projects" do
      expect(Project.accessible_by(ability, :read)).to be_empty
    end

    it "reads no tasks" do
      expect(Task.accessible_by(ability, :read)).to be_empty
    end
  end

  context "when signed in user" do
    let(:user) { create(:user) }

    it "reads exactly the publicly visible projects" do
      expect(ids_of(Project.accessible_by(ability, :read)))
        .to eq(ids_of(Project.publicly_visible))
    end

    it "reads exactly the publicly visible tasks" do
      expect(ids_of(Task.accessible_by(ability, :read)))
        .to eq(ids_of(Task.publicly_visible))
    end
  end

  context "when coordinator" do
    let(:user) { create(:user) }

    before do
      unpublished_project.coordinators << user
      unpublished_task.coordinators << user
    end

    # Coordinators can `:show` their own unpublished records, but `:read` only
    # covers the published ones, which is what the listings are built from.
    it "reads exactly the publicly visible projects" do
      expect(ids_of(Project.accessible_by(ability, :read)))
        .to eq(ids_of(Project.publicly_visible))
    end

    it "reads exactly the publicly visible tasks" do
      expect(ids_of(Task.accessible_by(ability, :read)))
        .to eq(ids_of(Task.publicly_visible))
    end

    it "shows exactly the publicly visible projects and the projects they coordinate" do
      expect(ids_of(Project.accessible_by(ability, :show)))
        .to eq(ids_of(Project.publicly_visible + [ unpublished_project ]))
    end

    it "shows exactly the publicly visible tasks and the tasks they coordinate" do
      expect(ids_of(Task.accessible_by(ability, :show)))
        .to eq(ids_of(Task.publicly_visible + [ unpublished_task ]))
    end
  end

  context "when editor" do
    let(:user) { create(:user, :editor) }

    it "reads all projects" do
      expect(ids_of(Project.accessible_by(ability, :read))).to eq(ids_of(Project.all))
    end

    it "reads all tasks" do
      expect(ids_of(Task.accessible_by(ability, :read))).to eq(ids_of(Task.all))
    end
  end

  context "when admin" do
    let(:user) { create(:user, :admin) }

    it "reads all projects" do
      expect(ids_of(Project.accessible_by(ability, :read))).to eq(ids_of(Project.all))
    end

    it "reads all tasks" do
      expect(ids_of(Task.accessible_by(ability, :read))).to eq(ids_of(Task.all))
    end
  end
end
