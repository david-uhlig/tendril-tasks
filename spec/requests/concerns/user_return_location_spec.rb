# frozen_string_literal: true

require "rails_helper"

class UserReturnLocationController < ActionController::Base
  include UserReturnLocation

  def index
    head :ok
  end

  def create
    head :ok
  end

  def update
    head :ok
  end

  def destroy
    head :ok
  end
end

class SkipUserReturnLocationController < ActionController::Base
  include UserReturnLocation

  skip_return_location_storage

  def index
    redirect_to_stored_location
  end
end

class UnskippedUserReturnLocationController < ActionController::Base
  include UserReturnLocation

  def index
    redirect_to_stored_location
  end
end

RSpec.describe UserReturnLocation, type: :request do
  around do |example|
    with_routing do |routes|
      routes.draw do
        root to: "user_return_location#index"
        resources :user_return_location, only: [ :index, :create, :update, :destroy ]
        resources :skip_user_return_location, only: [ :index ]
        resources :unskipped_user_return_location, only: [ :index ]
      end

      example.run
    end
  end

  describe "when requesting a resource" do
    context "with a GET request" do
      it "stores the user's request location" do
        get user_return_location_index_path
        expect(session[:user_return_to]).to eq(user_return_location_index_path)
      end
    end

    context "with other requests" do
      it "does not store the user's request location", :aggregate_failures do
        {
          post: user_return_location_index_path,
          patch: user_return_location_path(1),
          put: user_return_location_path(1),
          delete: user_return_location_path(1)
        }.each do |method, path|
          public_send(method, path)
          expect(response).to have_http_status(:ok)
          expect(session[:user_return_to]).to be_nil, "expected no location stored for #{method.upcase}"
        end
      end
    end

    context "that skips return location storage" do
      it "does not store the user's request location" do
        get skip_user_return_location_index_path
        expect(session[:user_return_to]).to be_nil
      end
    end
  end

  describe "when redirecting to the stored location" do
    it "redirects to the last unskipped resource" do
      get user_return_location_index_path
      get skip_user_return_location_index_path
      expect(response).to redirect_to(user_return_location_index_path)
    end

    it "raises an error when the stored location is the current location" do
      expect {
        get unskipped_user_return_location_index_path
      }.to raise_error(UserReturnLocation::InfiniteRedirectError)
    end
  end

  describe "when no location is stored" do
    it "redirects to the default path" do
      get skip_user_return_location_index_path
      expect(response).to redirect_to(root_path)
    end
  end
end
