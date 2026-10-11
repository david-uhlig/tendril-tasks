# frozen_string_literal: true

class Footer
  class Data
    # Changes whenever the footer changes, a legal page is added, changed or
    # removed, or the locale changes, since the footer's text is translated.
    def cache_key
      @cache_key ||= "footer/#{I18n.locale}/#{footer.cache_key_with_version}/#{legal_pages.cache_version}"
    end

    def legal
      @legal ||= legal_pages.pluck(:slug)
    end

    def sitemap
      @sitemap ||= Sitemap.load
    end

    def copyright
      footer.copyright
    end

    private

    def footer
      Footer.instance
    end

    def legal_pages
      Page.legal
    end
  end
end
