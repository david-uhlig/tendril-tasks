require "rails_helper"
require "cancan/matchers"

RSpec.describe Ability, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  subject(:ability) { described_class.new(user) }

  # The ability captures the current time when it is built. Frozen, so that
  # records created later in an example share it.
  before { freeze_time }

  let(:published_project) do
    create(:project, published_at: 1.day.ago, tasks: [ create(:task, published_at: 1.day.ago) ])
  end
  let(:published_task) { published_project.tasks.first }

  context "when guest" do
    let(:user) { nil }

    it { is_expected.to be_able_to(:read, Page) }
    it { is_expected.not_to be_able_to(:read, published_project) }
    it { is_expected.not_to be_able_to(:read, published_task) }
    it { is_expected.not_to be_able_to(:create, :direct_upload) }
  end

  context "when user" do
    let(:user) { create(:user) }

    it { is_expected.to be_able_to(:read, Page) }
    it { is_expected.not_to be_able_to(:manage, Page) }
    it { is_expected.not_to be_able_to(:show, :admin_settings) }
    it { is_expected.not_to be_able_to(:create, Project) }
    it { is_expected.not_to be_able_to(:create, Task) }

    describe "projects" do
      it "can read a published project with published tasks" do
        expect(ability).to be_able_to(:read, published_project)
      end

      it "cannot read an unpublished project" do
        project = create(:project, :not_published, tasks: [ create(:task, published_at: 1.day.ago) ])
        expect(ability).not_to be_able_to(:read, project)
      end

      it "cannot read a published project without published tasks" do
        project = create(:project, published_at: 1.day.ago, tasks: [ create(:task, :not_published) ])
        expect(ability).not_to be_able_to(:read, project)
      end

      it "cannot coordinate, update or destroy a project of other coordinators" do
        expect(ability).not_to be_able_to(:coordinate, published_project)
        expect(ability).not_to be_able_to(:update, published_project)
        expect(ability).not_to be_able_to(:destroy, published_project)
      end

      it "can show, coordinate, update and destroy an unpublished project they coordinate" do
        project = create(:project, :not_published, coordinators: [ user ])
        expect(ability).to be_able_to(:show, project)
        expect(ability).to be_able_to(:coordinate, project)
        expect(ability).to be_able_to(:update, project)
        expect(ability).to be_able_to(:destroy, project)
      end
    end

    describe "tasks" do
      it "can read a published task of a published project" do
        expect(ability).to be_able_to(:read, published_task)
      end

      it "cannot read an unpublished task" do
        task = create(:task, :not_published, project: published_project)
        expect(ability).not_to be_able_to(:read, task)
      end

      it "cannot read a published task of an unpublished project" do
        task = create(:task, published_at: 1.day.ago, project: create(:project, :not_published))
        expect(ability).not_to be_able_to(:read, task)
      end

      it "cannot coordinate, update or destroy a task of other coordinators" do
        expect(ability).not_to be_able_to(:coordinate, published_task)
        expect(ability).not_to be_able_to(:update, published_task)
        expect(ability).not_to be_able_to(:destroy, published_task)
      end

      it "can show, coordinate, update and destroy an unpublished task they coordinate" do
        task = create(:task, :not_published, coordinators: [ user ])
        expect(ability).to be_able_to(:show, task)
        expect(ability).to be_able_to(:coordinate, task)
        expect(ability).to be_able_to(:update, task)
        expect(ability).to be_able_to(:destroy, task)
      end
    end

    describe "users" do
      it "can update and destroy themselves" do
        expect(ability).to be_able_to(:update, user)
        expect(ability).to be_able_to(:destroy, user)
      end

      it "cannot update or destroy other users" do
        other = create(:user)
        expect(ability).not_to be_able_to(:update, other)
        expect(ability).not_to be_able_to(:destroy, other)
      end
    end

    describe "direct uploads" do
      it "cannot upload without coordinating anything" do
        expect(ability).not_to be_able_to(:create, :direct_upload)
      end

      it "can upload when coordinating a project" do
        create(:project, coordinators: [ user ])
        expect(ability).to be_able_to(:create, :direct_upload)
      end

      it "can upload when coordinating a task" do
        create(:task, coordinators: [ user ])
        expect(ability).to be_able_to(:create, :direct_upload)
      end
    end

    # The read rules must agree with the `publicly_visible` scopes that list
    # projects and tasks, including at the publishing instant.
    describe "agreement with the publicly_visible scopes" do
      let!(:projects) do
        [
          published_project,
          create(:project, published_at: 1.day.ago, tasks: [ create(:task, :not_published) ]),
          create(:project, :not_published, tasks: [ create(:task, published_at: 1.day.ago) ]),
          create(:project, published_at: Time.zone.now, tasks: [ create(:task, published_at: 1.day.ago) ]),
          create(:project, published_at: 1.day.ago, tasks: [ create(:task, published_at: Time.zone.now) ]),
          create(:project, published_at: 1.day.from_now, tasks: [ create(:task, published_at: 1.day.ago) ])
        ]
      end
      let(:tasks) { projects.flat_map(&:tasks) }

      it "can read exactly the publicly visible projects" do
        visible = Project.publicly_visible.to_a
        projects.each do |project|
          expect(ability.can?(:read, project)).to eq(visible.include?(project)),
                                                  "mismatch for project published at #{project.published_at.inspect}"
        end
      end

      it "can read exactly the publicly visible tasks" do
        visible = Task.publicly_visible.to_a
        tasks.each do |task|
          expect(ability.can?(:read, task)).to eq(visible.include?(task)),
                                               "mismatch for task published at #{task.published_at.inspect}"
        end
      end
    end
  end

  context "when editor" do
    let(:user) { create(:user, :editor) }

    it { is_expected.to be_able_to(:manage, Project) }
    it { is_expected.to be_able_to(:manage, Task) }
    it { is_expected.to be_able_to(:coordinate, published_project) }
    it { is_expected.to be_able_to(:coordinate, published_task) }
    it { is_expected.to be_able_to(:create, :direct_upload) }
    it { is_expected.not_to be_able_to(:manage, Page) }
    it { is_expected.not_to be_able_to(:show, :admin_settings) }
  end

  context "when admin" do
    let(:user) { create(:user, :admin) }

    it { is_expected.to be_able_to(:manage, Project) }
    it { is_expected.to be_able_to(:manage, Task) }
    it { is_expected.to be_able_to(:create, :direct_upload) }
    it { is_expected.to be_able_to(:manage, Page) }
    it { is_expected.to be_able_to(:show, :admin_settings) }
  end
end
