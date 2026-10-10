# frozen_string_literal: true

class Brand
  def updated_at
    @updated_at ||= Setting.updated_at
  end

  def logo
    @logo ||= Setting.brand_logo
  end

  # Memoized with `defined?`, since `||=` would read the setting again when
  # its value is `nil` or `false`.
  def name
    return @name if defined?(@name)

    @name = Setting.brand_name.presence
  end

  def display_name?
    return @display_name if defined?(@display_name)

    @display_name = Setting.display_brand_name?
  end
end
