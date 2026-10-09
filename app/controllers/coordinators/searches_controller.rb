# frozen_string_literal: true

class Coordinators::SearchesController < ApplicationController
  rescue_from CanCan::AccessDenied, with: :access_denied_handler

  NUM_SEARCH_RESULTS = 12

  # Displays search results in the dialog
  def index
    authorize! :read, :coordinator_search_results

    if params[:search].present?
      @coordinators = User.search(params[:search]).exclude_ids(params[:coordinator_ids]).limit(NUM_SEARCH_RESULTS)
    else
      # TODO return smarter default choices
      @coordinators = User.exclude_ids(params[:coordinator_ids]).limit(NUM_SEARCH_RESULTS)
    end
  end

  # Saves the dialog by replacing the coordinator list in the parent form through a turbo_stream request
  def create
    authorize! :assign, :coordinator_selections

    # Ignores ids of users that no longer exist, e.g. when a user was deleted
    # while the dialog was open.
    @coordinators = User.where(id: params[:coordinator_ids]).presence || [ current_user ]
  end

  private

  def access_denied_handler(exception)
    respond_to do |format|
      format.turbo_stream { head :forbidden }
    end
  end

  def current_ability
    @current_ability ||= CoordinatorSelectionAbility.new(current_user)
  end
end
