# frozen_string_literal: true

# Base class for application config classes
class BaseConfig < Anyway::Config
  # Honor the `rails_config_x` loader option, below credentials and ENV-vars.
  Anyway.loaders.insert_after :yml, :rails_config_x, RailsConfigXLoader

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
