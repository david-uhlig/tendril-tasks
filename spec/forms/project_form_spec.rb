require "rails_helper"

RSpec.describe ProjectForm do
  it_behaves_like "a coordinated record form", :project

  describe "#form_path" do
    it "is the project path for a persisted project" do
      project = create(:project)

      expect(described_class.new(project).form_path).to eq("/projects/#{project.id}")
    end

    it "is the projects path for a new project" do
      expect(described_class.new.form_path).to eq("/projects")
    end
  end
end
