Devise.setup do |config|
  config.omniauth :rocketchat,
                  ENV["ROCKETCHAT_CLIENT_ID"],
                  ENV["ROCKETCHAT_CLIENT_SECRET"],
                  client_options: {
                    site: ENV["ROCKETCHAT_WORKSPACE_URL"]
                  }
end
