require "rails_helper"

RSpec.describe "Profile", type: :request do
  let(:user) { create(:user) }

  describe "GET /profile" do
    it "requires authentication" do
      require_authentication_for { get profile_path }
    end

    context "when authenticated" do
      before(:each) { login_as(user) }

      it "displays the profile page" do
        get profile_path
        expect(response).to have_http_status(:success)
        expect(response.body).to include(user.name)
        expect(response.body).to include(user.email)
      end
    end
  end

  describe "DELETE /profile" do
    it "requires authentication" do
      require_authentication_for { delete profile_path }
    end

    context "when authenticated" do
      before(:each) { login_as(user) }

      it "deletes the user account and redirects to the root path" do
        expect {
          delete profile_path
        }.to change(User, :count).by(-1)

        expect(User.find_by(id: user.id)).to be_nil
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
