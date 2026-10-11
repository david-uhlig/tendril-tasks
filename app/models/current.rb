# frozen_string_literal: true

# Per-request (and per-job) state, reset after each request.
class Current < ActiveSupport::CurrentAttributes
  # Single-row records by class name, see `SingletonRecord.instance`.
  attribute :singleton_records
end
