require "rails_helper"

RSpec.describe "Task creation", type: :request do
  let(:editor) { create(:user, :editor) }
  let!(:project) { create(:project) }

  before do
    login_as(editor)
  end

  describe "GET /tasks/new" do
    it "renders the task form" do
      get new_task_path

      expect(response).to have_http_status(:success)
    end
  end
end
