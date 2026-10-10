class Setting < ApplicationRecord
  serialize :value, coder: JSON

  has_one_attached :attachment

  validates :key, presence: true, uniqueness: true
  validates :attachment,
            content_type: %i[png jpg],
            size: { less_than: 500.kilobytes },
            dimension: { min: 1..1, max: 2048..2048 }

  # Purging the brand logo touches its setting, so this also runs then.
  after_commit { Current.settings = nil }

  class << self
    def remove(key)
      find_by(key: key)&.destroy
    end

    # Returns when a setting was last changed.
    def updated_at
      cached.each_value.map(&:updated_at).max
    end

    def to_h
      pluck(:key, :value).to_h
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

    private

    # Declares a setting with a reader and a writer, e.g. `Setting.brand_name`
    # and `Setting.brand_name = "Acme"`. Boolean settings also get a predicate,
    # e.g. `Setting.display_brand_name?`.
    #
    # @param key [Symbol] The setting's key.
    # @param type [Symbol, nil] ActiveModel type the value is cast to when it is
    #   read and written. Pass `nil` to store the value as is, e.g. a Hash.
    # @param default [Object] Returned when the setting has no value.
    # @param maximum_length [Integer, nil] Maximum length of the value. Its error
    #   message is translated under `<key>_too_long`.
    def setting(key, type: :string, default: nil, maximum_length: nil)
      key = key.to_s
      caster = ActiveModel::Type.lookup(type) if type

      define_singleton_method(key) do
        value = get(key)&.value
        value = caster.cast(value) if caster
        value.nil? ? default.deep_dup : value
      end

      define_singleton_method(:"#{key}=") do |value|
        set(key, value: caster ? caster.cast(value) : value)
      end

      singleton_class.alias_method(:"#{key}?", key) if type == :boolean

      if maximum_length
        validates :value,
                  length: { maximum: maximum_length, too_long: :"#{key}_too_long" },
                  if: -> { self.key == key }
      end
    end

    def get(key)
      cached[key]
    end

    # Loads all settings once per request, as most pages read several of them.
    def cached
      Current.settings ||= all.index_by(&:key)
    end

    # Raises ActiveRecord::RecordInvalid when the value is invalid, since the
    # result of a setter method can't be checked.
    def set(key, value: nil)
      setting = find_or_initialize_by(key: key)
      setting.value = value
      setting.save!
    end
  end

  setting :brand_name, maximum_length: 100
  setting :display_brand_name, type: :boolean, default: true
  setting :footer_copyright, default: "", maximum_length: 255
  setting :footer_sitemap, type: nil, default: {}
end
