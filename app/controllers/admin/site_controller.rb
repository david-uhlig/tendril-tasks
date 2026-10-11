# frozen_string_literal: true

module Admin
  class SiteController < AdminController
    def edit
      @site = ::Site.instance
    end
  end
end
