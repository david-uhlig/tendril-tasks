# frozen_string_literal: true

module Admin
  class FooterController < AdminController
    def edit
      @sitemap = ::Footer::Sitemap.new(Setting.footer_sitemap)
      @copyright = Setting.footer_copyright
    end
  end
end
