class Setting < ApplicationRecord
  serialize :value, coder: JSON

  has_one_attached :attachment

  validates :key, presence: true, uniqueness: true
  validates :attachment,
            content_type: %i[png jpg],
            size: { less_than: 500.kilobytes },
            dimension: { min: 1..1, max: 2048..2048 }
  validates :value, length: { maximum: 100, too_long: :brand_name_too_long },
            if: -> { key == "brand_name" }
  validates :value, length: { maximum: 255, too_long: :footer_copyright_too_long },
            if: -> { key == "footer_copyright" }

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

    def save_brand_logo(uploaded_file)
      setting = find_or_initialize_by(key: "brand_logo")
      setting.attachment.attach(uploaded_file)
      setting.save
      setting
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

    # Raises ActiveRecord::RecordInvalid when the value is invalid, since the
    # result of a setter method can't be checked.
    def set(key, value: nil)
      setting = find_or_initialize_by(key: key)
      setting.value = value
      setting.save!
    end
  end
end
