# frozen_string_literal: true

module Gustwave
  # Validates a value against a fixed list where a component's declared
  # options don't reach, e.g. in a helper. Components declare their options
  # with Gustwave::Options instead.
  #
  # Follows the same policy as Gustwave::Options: an unknown value raises
  # when Gustwave.strict?, and falls back otherwise.
  #
  #   fetch_or_fallback([1, 2, 3], 5, 2) # => raises InvalidValueError, or 2 when not strict
  #   fetch_or_fallback([1, 2, 3], 1, 2) # => 1
  module FetchOrFallbackHelper
    # Raised when Gustwave.strict? for a value that isn't allowed.
    class InvalidValueError < Gustwave::Error; end

    # Returns +given_value+ if it is one of +allowed_values+, otherwise
    # +fallback+. Raises InvalidValueError instead when Gustwave.strict?.
    #
    # @param allowed_values [Array] the values that are allowed.
    # @param given_value [Object] the value to check.
    # @param fallback [Object] the value returned for a value that isn't allowed, when not strict.
    # @return [Object] +given_value+ when allowed, otherwise +fallback+.
    def fetch_or_fallback(allowed_values, given_value, fallback = nil)
      return given_value if allowed_values.include?(given_value)

      if Gustwave.strict?
        message = Options.suggest("Unknown value #{given_value.inspect}", given_value, allowed_values)
        raise InvalidValueError, "#{message}\n#{Options.fallback_note(fallback)}"
      end

      fallback
    end
  end
end
