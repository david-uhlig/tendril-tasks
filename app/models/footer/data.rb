# frozen_string_literal: true

module Footer
  class Data
    def updated_at
      @updated_at ||= [ Setting.maximum(:updated_at), Page.maximum(:updated_at) ].compact.max
    end

    def legal
      @legal ||= Page.where(slug: Admin::LegalController::LEGAL_PAGES)
                      .pluck(:slug)
    end

    def sitemap
      @sitemap ||= Setting.footer_sitemap.fetch("categories", {})
    end

    def copyright
      @copyright ||= Setting.footer_copyright
    end
  end
end
