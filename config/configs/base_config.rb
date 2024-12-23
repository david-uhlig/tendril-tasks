# frozen_string_literal: true

# Base class for application config classes
class BaseConfig < Anyway::Config
  def validate_required_attributes!
    # Disable required fields during asset precompilation
    # TODO remove this monkey patch when anyway_config will support SECRET_KEY_BASE_DUMMY
    # see: https://github.com/palkan/anyway_config/pull/152
    return if ENV["SECRET_KEY_BASE_DUMMY"] == "1"

    super
  end

  class << self
    # Make it possible to access a singleton config instance
    # via class methods (i.e., without explicitly calling `instance`)
    delegate_missing_to :instance

    private

    # Returns a singleton config instance
    def instance
      @instance ||= new
    end
  end
end
