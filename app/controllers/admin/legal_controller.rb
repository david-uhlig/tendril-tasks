# frozen_string_literal: true

module Admin
  class LegalController < ApplicationController
    LEGAL_PAGES = %w[ imprint privacy-policy terms-of-service ]

    def index
      authorize! :show, :admin_settings

      @pages = Page.where(slug: LEGAL_PAGES).pluck(:slug)
    end
  end
end
