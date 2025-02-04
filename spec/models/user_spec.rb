require 'rails_helper'

RSpec.describe User, type: :model do
  describe "#destroy" do
    let(:user) { create(:user) }

    it "deletes the user's task applications" do
      task_application = create(:task_application, user: user)
      user.destroy

      expect(
        TaskApplication.find_by(task: task_application.task,
                                user: task_application.user)
      ).to be_nil
    end

    it "keeps the projects the user is a coordinator of" do
      project = create(:project, coordinators: [ user ])
      user.destroy

      expect(Project.find_by(id: project.id)).to be_present
    end

    it "keeps the tasks the user is a coordinator of" do
      task = create(:task, coordinators: [ user ])
      user.destroy

      expect(Task.find_by(id: task.id)).to be_present
    end

    it "removes the user from the projects coordinators" do
      project = create(:project, coordinators: [ user ])
      user.destroy

      expect(Project.find_by(id: project.id).coordinators).to be_empty
    end

    it "removes the user from the tasks coordinators" do
      task = create(:task, coordinators: [ user ])
      user.destroy

      expect(Task.find_by(id: task.id).coordinators).to be_empty
    end
  end

  describe ".from_omniauth" do
    let(:auth) do
      OmniAuth::AuthHash.new(
        provider: "rocketchat",
        uid: "123456",
        info: {
          name: "John Doe",
          email: "john.doe@example.com",
          username: "john.doe",
          avatar: {
            url: "https://example.com/avatar/john.doe",
            etag: "55577fgdD"
          }
        }
      )
    end

    context "when user already exists" do
      it "returns the existing user" do
        existing_user = create(:user, provider: "rocketchat", uid: "123456", email: "test@example.com")

        user = User.from_omniauth(auth)

        expect(user).to eq(existing_user)
      end
    end

    context "when user does not exist" do
      it "creates a new user with the provided omniauth details" do
        expect { User.from_omniauth(auth) }.to change(User, :count).by(1)

        user = User.last
        expect(user.provider).to eq("rocketchat")
        expect(user.uid).to eq("123456")
        expect(user.email).to eq("john.doe@example.com")
        expect(user.encrypted_password).to be_present
        expect(user.name).to eq("John Doe")
        expect(user.username).to eq("john.doe")
        expect(user.avatar_url).to eq("https://example.com/avatar/john.doe")
      end
    end
  end

  describe "devise modules" do
    let(:user) { create(:user) }

    it "is valid with valid attributes" do
      expect(user).to be_valid
    end

    it "authenticates with a valid password" do
      authenticated_user = user.valid_password?("password")
      expect(authenticated_user).to be_truthy
    end

    it "does not authenticate with an invalid password" do
      authenticated_user = user.valid_password?("wrong_password")
      expect(authenticated_user).to be_falsey
    end
  end

  describe ".search" do
    let!(:user1) { create(:user, name: "First User", username: "some one") }
    let!(:user2) { create(:user, name: "Second Person", username: "some two") }
    let!(:user3) { create(:user, name: "Third User", username: "other three") }
    let!(:user4) { create(:user, name: "Nobody", username: "dummy") }

    it "returns users with matching names" do
      expect(User.search("User")).to contain_exactly(user1, user3)
    end

    it "accepts a case-insensitive search term" do
      expect(User.search("user")).to contain_exactly(user1, user3)
    end

    it "returns users with matching usernames" do
      expect(User.search("some")).to contain_exactly(user1, user2)
    end

    it "returns users with matching names or usernames" do
      max = create(:user, name: "Max Mustermann", username: "max.mustermann")
      john = create(:user, name: "John Doe", username: "john.mustermann")
      expect(User.search("Mustermann")).to contain_exactly(max, john)
    end

    it "returns an empty array when no users match the search" do
      expect(User.search("Foo")).to be_empty
    end

    it "returns all users when the search term is blank" do
      expect(User.search("")).to contain_exactly(user1, user2, user3, user4)
    end
  end
end
