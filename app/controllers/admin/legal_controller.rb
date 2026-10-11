# frozen_string_literal: true

module Admin
  class LegalController < AdminController
    def index
      @pages = Page.legal.pluck(:slug)
    end
  end
end
