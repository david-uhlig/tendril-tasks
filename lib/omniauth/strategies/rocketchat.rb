require "omniauth-oauth2"

# TODO Turn this strategy into a gem
# TODO Add tests and config
# TODO Add documentation
module OmniAuth
  module Strategies
    class RocketChat < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, "rocketchat"

      # You may specify that your strategy should use PKCE by setting
      # the pkce option to true: https://tools.ietf.org/html/rfc7636
      option :pkce, true

      # These are called after authentication has succeeded. If
      # possible, you should try to set the UID without making
      # additional calls (if the user id is returned with the token
      # or as a URI parameter). This may not be possible with all
      # providers.
      uid { raw_info["_id"] }

      info do
        {
          name: raw_info["name"],
          email: raw_info["email"],
          username: raw_info["username"],
          image: raw_info["avatar_url"]
        }
      end

      extra do
        {
          "raw_info" => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get("/api/v1/me").parsed
      end

      def callback_url
        full_host + callback_path
      end
    end
  end
end

OmniAuth.config.add_camelization "rocketchat", "RocketChat"
