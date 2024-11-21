require 'rails_helper'

RSpec.describe "Root path", type: :request do
  describe "GET /" do
    it 'loads successfully' do
      expect {
        get root_path
      }.not_to raise_error
      expect(response).to have_http_status(:success)
    end
  end
end
