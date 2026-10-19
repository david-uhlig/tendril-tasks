require "rails_helper"

RSpec.describe TaskForm do
  it_behaves_like "a coordinated record form", :task

  describe "#project_id=" do
    it "assigns the project" do
      project = create(:project)
      form = described_class.new(create(:task))

      form.project_id = project.id

      expect(form.project).to eq(project)
    end
  end

  describe "#project_options" do
    it "returns the projects ordered by title" do
      create(:project, title: "Zebra")
      create(:project, title: "Apple")
      create(:project, title: "Mango")

      expect(described_class.new.project_options.map(&:title)).to eq(%w[ Apple Mango Zebra ])
    end
  end

  describe "#form_path" do
    it "is the task path for a persisted task" do
      task = create(:task)

      expect(described_class.new(task).form_path).to eq("/tasks/#{task.id}")
    end

    it "is the tasks path for a new task" do
      expect(described_class.new.form_path).to eq("/tasks")
    end
  end
end
