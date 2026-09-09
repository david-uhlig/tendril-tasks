# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Admin Legal", type: :request do
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  describe "GET /admin/legal" do
    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        get admin_legal_index_path
        expect(response).to redirect_to(new_user_session_path)
      end

      it "rejects unauthorized users" do
        login_as(editor)
        get admin_legal_index_path
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path)
      end

      it "allows authorized users" do
        login_as(admin)
        get admin_legal_index_path
        expect(response).to have_http_status(:success)
      end
    end
  end
end
