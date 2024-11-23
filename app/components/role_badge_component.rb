# frozen_string_literal: true

# Renders roles badges depending on the given users role.
class RoleBadgeComponent < ApplicationComponent
  DEFAULT_ROLE_SCHEME = :user
  # Maps user role to badge scheme
  ROLE_SCHEME_MAPPINGS = {
    admin: :purple,
    editor: :default,
    user: :default
  }
  ROLE_SCHEME_OPTIONS = ROLE_SCHEME_MAPPINGS.keys
  DEFAULT_SIZE = :small
  DEFAULT_BORDER = true

  def initialize(user, **options)
    @user = user
    @options = build_options(options, user)
  end

  private

  def build_options(options, user)
    options.stringify_keys!
    options["scheme"] ||= ROLE_SCHEME_MAPPINGS[fetch_or_fallback(ROLE_SCHEME_OPTIONS, user.role.to_sym, DEFAULT_ROLE_SCHEME)]
    options["size"] ||= DEFAULT_SIZE
    options["border"] ||= DEFAULT_BORDER
    options.symbolize_keys!
    options
  end
end
