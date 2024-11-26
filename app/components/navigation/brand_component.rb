# frozen_string_literal: true

module Navigation
  class BrandComponent < ApplicationComponent
    def initialize
      @src = brand_logo
      @badge = ENV["BRAND_BADGE"] || "Aufgabenportal"
    end

    private

    def brand_logo
      return "brand/custom/logo.svg" if File.exist?(
        Rails.root.join("app", "assets", "images", "brand", "custom", "logo.svg")
      )

      "brand/default_logo.svg"
    end
  end
end
