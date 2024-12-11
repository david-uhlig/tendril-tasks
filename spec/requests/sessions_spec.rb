require 'rails_helper'

RSpec.describe 'User Sessions', type: :request do
  describe 'GET /users/sign_in' do
    it 'renders the sign-in page' do
      get new_user_session_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include('Willkommen zurück')
    end
  end

  describe 'POST /users/sign_in' do
    it 'is disabled and returns a 404 or 405' do
      post '/users/sign_in'
      expect(response).to have_http_status(:not_found).or have_http_status(:method_not_allowed)
    end
  end

  describe 'DELETE /users/sign_out' do
    it 'is enabled and returns a 303' do
      delete destroy_user_session_path

      expect(response).to have_http_status(:see_other)
      expect(response).to redirect_to(root_path)

      # Ensure the session is cleared and user is logged out
      follow_redirect!
      expect(controller.current_user).to be_nil
    end
  end
end
