class Setting < ApplicationRecord
  include SvgSanitizable

  serialize :value, coder: JSON

  has_one_attached :attachment

  validates :key, presence: true, uniqueness: true
  validates :attachment,
            content_type: %i[png jpg jpeg svg],
            size: { less_than: 500.kilobytes }

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
      get("brand_logo")&.attachment&.attachment
    end

    def brand_logo=(uploaded_file)
      set("brand_logo", attachment: uploaded_file)
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
      if attachment.present?
        sanitized_file = Setting.new.sanitize_svg(attachment)
        setting.attachment.attach(sanitized_file)
      end
      setting.save
    end
  end
end
