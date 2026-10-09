require 'rails_helper'

RSpec.describe "Root path", type: :request do
  describe "GET /" do
    context "as a visitor" do
      it "loads the root page" do
        get root_path

        expect(response).to have_http_status(:success)
      end
    end

    context "as a user" do
      let(:user) { create(:user) }

      it "loads the root page" do
        login_as(user)

        get root_path

        expect(response).to have_http_status(:success)
      end
    end
  end
end
