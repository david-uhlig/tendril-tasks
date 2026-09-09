# frozen_string_literal: true

module Admin
  class LegalController < AdminController
    LEGAL_PAGES = %w[ imprint privacy-policy terms-of-service ]

    def index
      @pages = Page.where(slug: LEGAL_PAGES).pluck(:slug)
    end
  end
end
