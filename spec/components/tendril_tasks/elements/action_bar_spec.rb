require "rails_helper"

RSpec.describe TendrilTasks::Elements::ActionBar, type: :component do
  let(:routes) { Rails.application.routes.url_helpers }
  let(:edit_label) { "Bearbeiten" }
  let(:add_task_label) { "Aufgabe" }
  let(:add_project_label) { "Thema" }

  let(:editor) { create(:user, :editor) }
  let(:coordinator) { create(:user) }
  let(:other_coordinator) { create(:user) }
  let(:stranger) { create(:user) }

  let(:project) do
    create(:project, :published, coordinators: [ coordinator, other_coordinator ])
  end
  let(:task) do
    create(:task, :published, project: project, coordinators: [ coordinator ])
  end

  context "with a task" do
    let(:element) { task }

    context "when the user is an editor" do
      before { as(editor) }

      it "links to editing the task" do
        render_inline(described_class.new(element))

        expect(page).to have_link(edit_label, href: routes.edit_task_path(task))
      end

      it "links to a new task from the task's project preset" do
        render_inline(described_class.new(element))

        expect(page).to have_link(
          add_task_label,
          href: routes.new_task_from_preset_path(project_id: project.id,
                                                 coordinator_ids: project.coordinator_ids.join("-"))
        )
      end

      it "links to creating an initiative" do
        render_inline(described_class.new(element))

        expect(page).to have_link(add_project_label, href: routes.new_project_path)
      end
    end

    context "when the user can create tasks and projects but not update the task" do
      before do
        as(editor)
        allow(vc_test_controller).to receive(:can?).and_call_original
        allow(vc_test_controller).to receive(:can?).with(:update, task).and_return(false)
      end

      it "hides the edit link" do
        render_inline(described_class.new(element))

        expect(page).to have_no_link(edit_label)
      end

      it "still shows the add task link" do
        render_inline(described_class.new(element))

        expect(page).to have_link(add_task_label)
      end
    end

    context "when the user is a coordinator of the task only" do
      before { as(coordinator) }

      it "links to editing the task" do
        render_inline(described_class.new(element))

        expect(page).to have_link(edit_label, href: routes.edit_task_path(task))
      end

      it "hides the add task link" do
        render_inline(described_class.new(element))

        expect(page).to have_no_link(add_task_label)
      end

      it "hides the add initiative link" do
        render_inline(described_class.new(element))

        expect(page).to have_no_link(add_project_label)
      end
    end

    context "when the user cannot update or create anything" do
      before { as(stranger) }

      it "renders nothing" do
        render_inline(described_class.new(element))

        expect(rendered_content).to be_blank
      end
    end
  end

  context "with a project" do
    let(:element) { project }

    context "when the user is an editor" do
      before { as(editor) }

      it "links to editing the project" do
        render_inline(described_class.new(element))

        expect(page).to have_link(edit_label, href: routes.edit_project_path(project))
      end

      it "links to a new task from the project's own preset" do
        render_inline(described_class.new(element))

        expect(page).to have_link(
          add_task_label,
          href: routes.new_task_from_preset_path(project_id: project.id,
                                                 coordinator_ids: project.coordinator_ids.join("-"))
        )
      end

      it "links to creating an initiative" do
        render_inline(described_class.new(element))

        expect(page).to have_link(add_project_label, href: routes.new_project_path)
      end
    end

    context "when the user can create initiatives and tasks but not update the project" do
      before do
        as(editor)
        allow(vc_test_controller).to receive(:can?).and_call_original
        allow(vc_test_controller).to receive(:can?).with(:update, project).and_return(false)
      end

      it "hides the edit link" do
        render_inline(described_class.new(element))

        expect(page).to have_no_link(edit_label)
      end

      it "still shows the add initiative link" do
        render_inline(described_class.new(element))

        expect(page).to have_link(add_project_label)
      end
    end

    context "when the user is a coordinator of the project only" do
      before { as(coordinator) }

      it "links to editing the project" do
        render_inline(described_class.new(element))

        expect(page).to have_link(edit_label, href: routes.edit_project_path(project))
      end

      it "hides the add task and add initiative links" do
        render_inline(described_class.new(element))

        expect(page).to have_no_link(add_task_label)
        expect(page).to have_no_link(add_project_label)
      end
    end

    context "when the user cannot update or create anything" do
      before { as(stranger) }

      it "renders nothing" do
        render_inline(described_class.new(element))

        expect(rendered_content).to be_blank
      end
    end
  end
end
