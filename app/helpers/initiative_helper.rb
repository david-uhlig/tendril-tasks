module InitiativeHelper
  COLORS = Gustwave::Badge.option_values(:color).excluding(:none, :base).freeze

  def badge_color_by_id(id)
    COLORS.fetch(id % COLORS.size)
  end
end
