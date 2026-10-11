# frozen_string_literal: true

# Per-request (and per-job) state, reset after each request.
class Current < ActiveSupport::CurrentAttributes
  # All settings by key, see `Setting.cached`.
  attribute :settings
  # Single-row records by class name, see `SingletonRecord.instance`.
  attribute :singleton_records
end
