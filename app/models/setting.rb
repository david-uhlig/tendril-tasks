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
