# frozen_string_literal: true

module Footer
  class Sitemap
    include ActiveModel::Model
    include ActiveModel::Serialization

    attr_accessor :categories

    validates :categories, presence: true
    validate :categories_valid?

    def initialize(attributes = {})
      super

      @categories = attributes.fetch("categories", []).map { Footer::Category.new(it) }
    end

    def save
      return false unless valid?

      Setting.footer_sitemap = attributes
    end

    def destroy
      Setting.remove("footer_sitemap")
    end

    def attributes
      {
        "categories" => categories.map(&:attributes)
      }
    end

    private

    def categories_valid?
      categories.all?(&:valid?).tap do |all_categories_valid|
        next if all_categories_valid
        # Collect errors
        categories.each { |category| errors.merge!(category.errors) unless category.valid? }
      end
    end
  end
end
