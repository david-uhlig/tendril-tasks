# frozen_string_literal: true

module Admin
  class FooterController < ApplicationController
    def edit
      authorize! :edit, :admin_settings

      @sitemap = ::Footer::Sitemap.new(Setting.footer_sitemap)
    end
  end
end
