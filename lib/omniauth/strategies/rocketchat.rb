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

      uid do
        raw_info["_id"]
      end

      info do
        {
          email: raw_info["email"],
          active: raw_info["active"],
          roles: raw_info["roles"],
          name: raw_info["name"],
          username: raw_info["username"],
          avatar: {
            url: raw_info["avatar_url"],
            e_tag: raw_info["avatar_e_tag"],
            origin: raw_info["avatar_origin"]
          }
        }
      end

      extra do
        {
          raw_info: raw_info
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
