# frozen_string_literal: true

# Root component from which all other components inherit
#
# Conventions:
# * Component names end in -Component
# * Component module names are plural, as for controllers and jobs, e.g.
#   `Users::AvatarComponent`
# * Name components for what they render, not what they accept, e.g.
#   `AvatarComponent` instead of `UserComponent`
#
# @see https://viewcomponent.org/guide/getting-started.html#conventions
class ApplicationComponent < Gustwave::Component
  include Primer::FetchOrFallbackHelper
  include TailwindHelper

  delegate :paragraphize, to: :view_context
  delegate :rocketchat_applink, :rocketchat_link, to: :view_context
  delegate :current_user, :user_signed_in?, to: :view_context
  delegate :can?, :cannot?, to: :view_context
  delegate :turbo_stream, to: :view_context
end
