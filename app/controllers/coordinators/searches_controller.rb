class Coordinators::SearchesController < ApplicationController
  NUM_SEARCH_RESULTS = 12

  before_action :authenticate_user!

  # Displays search results in the dialog
  def index
    if params[:search].present?
      @coordinators = User.search(params[:search]).exclude_ids(params[:coordinator_ids]).limit(NUM_SEARCH_RESULTS)
    else
      # TODO return smarter default choices
      @coordinators = User.exclude_ids(params[:coordinator_ids]).limit(NUM_SEARCH_RESULTS)
    end
  end

  # Saves the dialog by replacing the coordinator list in the parent form through a turbo_stream request
  def create
    if params[:coordinator_ids].present?
      @coordinators = User.find(params[:coordinator_ids])
    else
      @coordinators = [ current_user ]
    end
  end
end
