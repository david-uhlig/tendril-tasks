# frozen_string_literal: true

# Base component from which all other components inherit
#
# Conventions:
# * Component names end in -Component
# * Component module names are plural, as for controllers and jobs, e.g.
#   `Users::AvatarComponent`
# * Name components for what they render, not what they accept, e.g.
#   `AvatarComponent` instead of `UserComponent`
#
# @see https://viewcomponent.org/guide/getting-started.html#conventions
class BaseComponent < ViewComponent::Base
  include Primer::FetchOrFallbackHelper
  include Primer::ClassNameHelper
end
