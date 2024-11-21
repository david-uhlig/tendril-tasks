class Coordinators::SearchesController < ApplicationController
  before_action :authenticate_user!

  # Displays search results in the dialog
  def index
    if params[:search].present?
      @coordinators = User.search(params[:search]).exclude_ids(params[:coordinator_ids]).limit(15)
    else
      # TODO return smarter default choices
      @coordinators = User.exclude_ids(params[:coordinator_ids]).limit(15)
    end
  end

  # Saves the dialog by replacing the coordinator list in the parent form through a turbo_stream request
  def create
    @coordinators = User.find(params[:coordinator_ids])
  end
end
