# frozen_string_literal: true

module Admin
  class PagesController < ApplicationController
    PERMISSIVE_PAGES = %w[ imprint privacy-policy terms-of-service ]

    before_action :set_slug
    before_action :set_page

    def edit
    end

    def update
    end

    def destroy
    end

    private

    def set_page
      @page = Page.find_or_create_by(slug: @slug)
    end

    def set_slug
      unless params[:slug].in?(PERMISSIVE_PAGES)
        raise ActionController::RoutingError, "Not Found"
      end

      @slug ||= params[:slug]
    end
  end
end
