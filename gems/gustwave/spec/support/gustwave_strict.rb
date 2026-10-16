# frozen_string_literal: true

RSpec.configure do |config|
  # Restores the default strictness after examples that set it.
  config.after { Gustwave.strict = nil }
end
