require "rails_helper"

RSpec.describe "Admin User Roles", type: :request do
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }

  describe "GET /admin/users/roles" do
    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        require_authentication_for { get admin_users_roles_path }
      end

      it "rejects unauthorized users" do
        login_as(editor)
        get admin_users_roles_path

        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path)
      end

      it "allows authorized users" do
        login_as(admin)
        get admin_users_roles_path

        expect(response).to have_http_status(:success)
        expect(response.body).to include(admin.name)
      end
    end
  end

  describe "PATCH /admin/users/roles/:id" do
    let(:user) { create(:user, :editor) }

    context "requires admin authorization" do
      it "redirects unauthenticated users to the login page" do
        require_authentication_for do
          patch admin_users_role_path(user), params: { role: "admin" }, as: :turbo_stream
        end
      end

      it "rejects unauthorized users" do
        login_as(editor)
        expect(user.role).to eq("editor")

        patch admin_users_role_path(user), params: { role: "admin" }, as: :turbo_stream

        expect(user.reload.role).to eq("editor")
        expect(response).to have_http_status(:not_found)
      end
    end

    context "when authorized" do
      before { login_as(admin) }

      it "updates the user's role" do
        expect {
          patch admin_users_role_path(user), params: { role: "admin" }, as: :turbo_stream
        }.to change { user.reload.role }.from("editor").to("admin")

        expect(response).to have_http_status(:success)
      end

      it "refuses to change the current user's role" do
        expect(admin.role).to eq("admin")
        patch admin_users_role_path(admin), params: { role: "editor" }, as: :turbo_stream

        expect(response).to have_http_status(:success)
        expect(admin.reload.role).to eq("admin")
      end
    end
  end
end
