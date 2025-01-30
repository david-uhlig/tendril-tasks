class Setting < ApplicationRecord
  serialize :value, coder: JSON

  has_many_attached :attachments

  validates :key, presence: true, uniqueness: true

  class << self
    def remove(key)
      find_by(key: key)&.destroy
    end

    def to_h
      pluck(:key, :value).to_h
    end

    def footer_sitemap
      get("footer_sitemap")&.value || {}
    end

    def footer_sitemap=(value)
      set("footer_sitemap", value: value)
    end

    def footer_copyright
      get("footer_copyright")&.value || ""
    end

    def footer_copyright=(value)
      set("footer_copyright", value: value)
    end

    def brand_logo
      get("brand_logo")&.attachments&.first
    end

    def brand_logo=(attachment)
      get("brand_logo")&.attachments&.each(&:purge)
      set("brand_logo", attachment: attachment)
    end

    def display_brand_name?
      value = get("display_brand_name")&.value
      value.nil? || ActiveRecord::Type::Boolean.new.cast(value)
    end

    def display_brand_name=(value)
      set("display_brand_name", value: value)
    end

    def brand_name
      get("brand_name")&.value
    end

    def brand_name=(value)
      set("brand_name", value: value)
    end

    private

    def get(key)
      find_by(key: key)
    end

    def set(key, value: nil, attachment: nil)
      setting = find_or_initialize_by(key: key)

      setting.value = value
      setting.attachments.attach(attachment) if attachment.present?
      setting.save
    end
  end
end
