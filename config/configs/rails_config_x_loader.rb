# frozen_string_literal: true

# Loads a config from `Rails.application.config.x.<config name>`, when the
# config opts in with `loader_options rails_config_x: true`. This lets the app
# or an engine extend a config in Ruby, e.g. in an environment file:
#
#   config.x.content_security_policy.script_src = "https://cdn.example.com"
#
# Credentials and ENV-vars take precedence.
class RailsConfigXLoader < Anyway::Loaders::Base
  def call(name:, rails_config_x: false, **)
    return {} unless rails_config_x

    trace!(:rails_config_x) do
      ::Rails.application.config.x.public_send(name).to_h
    end
  end
end
