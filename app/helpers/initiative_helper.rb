module InitiativeHelper
  SCHEME_OPTIONS = Gustwave::Badge::SCHEME_OPTIONS
  SCHEME_SIZE = SCHEME_OPTIONS.size

  def badge_scheme_by_id(id)
    SCHEME_OPTIONS.fetch(id % SCHEME_SIZE)
  end
end
