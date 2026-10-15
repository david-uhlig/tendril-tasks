# frozen_string_literal: true

module Gustwave
  # Validates a value against a fixed list where a component's declared
  # options don't reach, e.g. in a helper. Components declare their options
  # with Gustwave::Options instead.
  #
  # Follows the same policy as Gustwave::Options: an unknown value raises
  # outside production, and falls back in production.
  #
  #   fetch_or_fallback([1, 2, 3], 5, 2) # => raises InvalidValueError, or 2 in production
  #   fetch_or_fallback([1, 2, 3], 1, 2) # => 1
  module FetchOrFallbackHelper
    # Raised outside production for a value that isn't allowed.
    class InvalidValueError < Gustwave::Error; end

    def fetch_or_fallback(allowed_values, given_value, fallback = nil)
      return given_value if allowed_values.include?(given_value)

      if Options.strict?
        message = Options.suggest("Unknown value #{given_value.inspect}", given_value, allowed_values)
        raise InvalidValueError, "#{message}\nIn production, this falls back to #{fallback.inspect}."
      end

      fallback
    end
  end
end
