class Setting < ApplicationRecord
  serialize :value, coder: JSON

  validates :key, presence: true, uniqueness: true
  validates :value, presence: true

  after_save :expire_cache
  after_destroy :expire_cache

  def self.get(key)
    find_by_key(key).try(:value)
  end

  def self.set(key, value)
    setting = Setting.find_or_initialize_by(key: key)
    setting.value = value
    setting.save
  end

  def self.delete(key)
    Setting.delete_by(key: key)
  end

  def self.to_h
    all.each_with_object({}) do |setting, hash|
      hash[setting.key] = setting.value
    end
  end

  def self.footer_sitemap
    Setting.get("footer_sitemap") || {}
  end

  def self.footer_sitemap=(value)
    Setting.set("footer_sitemap", value)
  end

  private

  def expire_cache
    Rails.cache.delete("footer_data")
  end
end
