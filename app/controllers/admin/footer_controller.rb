# frozen_string_literal: true

module Admin
  class FooterController < AdminController
    def edit
      @sitemap = ::Footer::Sitemap.load
      @copyright = ::Footer.instance.copyright
    end
  end
end
