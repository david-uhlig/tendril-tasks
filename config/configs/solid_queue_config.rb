# frozen_string_literal: true

# Configures how Solid Queue runs inside Puma.
#
# Read in `config/puma.rb`, before the application is initialized, and in
# `config/database.yml` for the pool size of the queue database.
class SolidQueueConfig < BaseConfig
  MODES = %w[async fork].freeze
  # In async mode, web threads, worker threads, polling and heartbeats all
  # share the queue database's pool.
  ASYNC_DB_POOL = 10

  config_name :solid_queue

  # Whether to run the Solid Queue supervisor inside the web server's Puma
  # process (`SOLID_QUEUE_IN_PUMA`).
  attr_config in_puma: false
  # How the supervisor runs the worker, dispatcher and scheduler
  # (`SOLID_QUEUE_MODE`). `async` runs them as threads in the Puma process,
  # which saves memory. `fork` runs them as separate processes, which isolates
  # them from the web server.
  attr_config mode: "fork"
  # Connection pool size of the queue database (`SOLID_QUEUE_DB_POOL`).
  # Defaults to `ASYNC_DB_POOL` in async mode inside Puma, and to the pool of
  # the other databases otherwise.
  attr_config :db_pool

  coerce_types in_puma: :boolean, mode: :string, db_pool: :integer

  on_load :validate_mode

  # Returns whether the supervisor runs in threads of the Puma process.
  def async_in_puma?
    in_puma && mode == "async"
  end

  # Returns the pool size of the queue database, or nil to use the default.
  def queue_database_pool
    db_pool || (ASYNC_DB_POOL if async_in_puma?)
  end

  private

  def validate_mode
    return if MODES.include?(mode)

    raise_validation_error("SOLID_QUEUE_MODE must be one of #{MODES.join(", ")}, got #{mode.inspect}")
  end
end
