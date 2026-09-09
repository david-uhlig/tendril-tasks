require "rails_helper"

RSpec.describe "Task navigation", type: :request do
  let(:user) { create(:user) }
  let!(:task) do
    create(
      :task,
      :published,
      :with_published_project,
      title: "Task Title 42"
    )
  end

  before do
    login_as(user)
  end

  it "links to the task detail page from the task index" do
    get tasks_path

    expect(response).to have_http_status(:success)
    expect(response.body).to include(%(href="#{task_path(task)}"))
  end

  it "renders the task detail page" do
    get task_path(task)

    expect(response).to have_http_status(:success)
    expect(response.body).to include(task.title)
    expect(response.body).to include("Interessiert? Hier melden!")
  end
end
