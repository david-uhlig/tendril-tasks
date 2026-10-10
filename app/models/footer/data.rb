# frozen_string_literal: true

module Footer
  class Data
    # Changes whenever a setting or a legal page is added, changed or removed,
    # and when the locale changes, since the footer's text is translated.
    def cache_key
      @cache_key ||= "footer/#{I18n.locale}/#{Setting.cache_version}/#{legal_pages.cache_version}"
    end

    def legal
      @legal ||= legal_pages.pluck(:slug)
    end

    def sitemap
      @sitemap ||= Sitemap.load
    end

    def copyright
      @copyright ||= Setting.footer_copyright
    end

    private

    def legal_pages
      Page.where(slug: Admin::LegalController::LEGAL_PAGES)
    end
  end
end
