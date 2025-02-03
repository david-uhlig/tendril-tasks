require 'rails_helper'

RSpec.describe "Root path", type: :request do
  describe "GET /" do
    context "as a visitor" do
      it "loads the root page" do
        expect {
          get root_path
        }.not_to raise_error

        expect(response).to have_http_status(:success)
      end
    end

    context "as a user" do
      let(:user) { create(:user) }

      it "loads the root page" do
        login_as(user)

        expect {
          get root_path
        }.not_to raise_error

        expect(response).to have_http_status(:success)
      end
    end
  end
end
