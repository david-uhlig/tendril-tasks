require "rails_helper"

RSpec.describe "Legal Pages", type: :request do
  let(:user) { create(:user) }
  let(:editor) { create(:user, :editor) }
  let(:admin) { create(:user, :admin) }
  let(:page) { create(:page, slug: :imprint, content: "Hello, World!") }

  describe "GET /legal/:slug" do
    it "is publicly accessible" do
      page
      get legal_path(:imprint)
      expect(response).to have_http_status(:success)
    end

    it "returns not found when the page does not exist" do
      get legal_path(:imprint)
      expect(response).to have_http_status(:not_found)
    end

    it "returns not found for non-legal pages" do
      create(:page, slug: :about, content: "About Us")
      get legal_path(:about)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe "GET /legal/:slug/edit" do
    context "requires admin authorization" do
      it "rejects unauthenticated users" do
        page
        get edit_legal_path(:imprint)
        expect(response).to have_http_status(:not_found)
      end

      it "rejects unauthorized users" do
        login_as(editor)
        page
        get edit_legal_path(:imprint)
        expect(response).to have_http_status(:not_found)
      end
    end

    context "with admin authorization" do
      before(:each) { login_as(admin) }

      it "allows editing existing legal pages" do
        page
        get edit_legal_path(:imprint)
        expect(response).to have_http_status(:success)
      end

      it "allows creating new legal pages" do
        get edit_legal_path(:imprint)
        expect(response).to have_http_status(:success)
      end

      it "rejects editing non-legal pages" do
        create(:page, slug: :about, content: "About Us")
        get edit_legal_path(:about)
        expect(response).to have_http_status(:not_found)
      end

      it "rejects creating non-legal pages" do
        get edit_legal_path(:about)
        expect(response).to have_http_status(:not_found)
      end
    end
  end

  describe "PATCH /legal/:slug" do
    let(:page_attributes) { { content: "Updated content" } }

    context "requires admin authorization" do
      it "rejects unauthenticated users" do
        page
        expect(page.content.body.to_s).to include("Hello, World!")
        patch legal_path(:imprint), params: { page: page_attributes }
        expect(response).to have_http_status(:not_found)
        expect(page.reload.content.body.to_s).to include("Hello, World!")
      end

      it "rejects unauthorized users" do
        login_as(editor)
        page
        expect(page.content.body.to_s).to include("Hello, World!")
        patch legal_path(:imprint), params: { page: page_attributes }
        expect(response).to have_http_status(:not_found)
        expect(page.reload.content.body.to_s).to include("Hello, World!")
      end
    end

    context "with admin authorization" do
      before(:each) { login_as(admin) }

      it "allows updating existing legal pages" do
        page
        expect(page.content.body.to_s).to include("Hello, World!")
        patch legal_path(:imprint), params: { page: page_attributes }
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(legal_path(:imprint))
        expect(page.reload.content.body.to_s).to include("Updated content")
      end

      it "allows creating new legal pages" do
        expect(Page.find_by(slug: :imprint)).to be_nil
        patch legal_path(:imprint), params: { page: page_attributes }
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(legal_path(:imprint))
        expect(Page.find_by(slug: :imprint)).not_to be_nil
      end

      it "rejects updating non-legal pages" do
        create(:page, slug: :about, content: "About Us")
        patch legal_path(:about), params: { page: page_attributes }
        expect(response).to have_http_status(:not_found)
        expect(Page.find_by(slug: :about).content.body.to_s).to include("About Us")
      end

      it "rejects creating non-legal pages" do
        expect(Page.find_by(slug: :about)).to be_nil
        patch legal_path(:about), params: { page: page_attributes }
        expect(response).to have_http_status(:not_found)
        expect(Page.find_by(slug: :about)).to be_nil
      end
    end
  end

  describe "DELETE /legal/:slug" do
    context "requires admin authorization" do
      it "rejects unauthenticated users" do
        page
        delete legal_path(:imprint)
        expect(response).to have_http_status(:not_found)
        expect(Page.find_by(slug: :imprint)).not_to be_nil
      end

      it "rejects unauthorized users" do
        login_as(editor)
        page
        delete legal_path(:imprint)
        expect(response).to have_http_status(:not_found)
        expect(Page.find_by(slug: :imprint)).not_to be_nil
      end
    end

    context "with admin authorization" do
      before(:each) { login_as(admin) }

      it "deletes existing legal pages" do
        page
        delete legal_path(:imprint)
        expect(response).to have_http_status(:found)
        expect(response).to redirect_to(root_path)
        expect(Page.find_by(slug: :imprint)).to be_nil
      end

      it "rejects deleting non-legal pages" do
        create(:page, slug: :about, content: "About Us")
        delete legal_path(:about)
        expect(response).to have_http_status(:not_found)
        expect(Page.find_by(slug: :about)).not_to be_nil
      end

      it "rejects deleting non-existing legal pages" do
        delete legal_path(:imprint)
        expect(response).to have_http_status(:not_found)
        expect(Page.find_by(slug: :imprint)).to be_nil
      end
    end
  end
end
