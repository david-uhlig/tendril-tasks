module InitiativeHelper
  SCHEMES = Gustwave::Badge.option_values(:scheme).excluding(:none, :base).freeze

  def badge_scheme_by_id(id)
    SCHEMES.fetch(id % SCHEMES.size)
  end
end
