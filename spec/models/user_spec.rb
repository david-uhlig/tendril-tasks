require 'rails_helper'

RSpec.describe User, type: :model do
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
end
