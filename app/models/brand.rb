# frozen_string_literal: true

class Brand
  def updated_at
    @updated_at ||= Setting.maximum(:updated_at)
  end

  def logo
    @logo ||= Setting.brand_logo || tendril_tasks_logo
  end

  def name
    @name ||= Setting.brand_name.presence || "Tendril Tasks"
  end

  def display_name?
    @display_name ||= Setting.display_brand_name?
  end

  private

  def tendril_tasks_logo
    "brand/logo.svg"
  end
end
