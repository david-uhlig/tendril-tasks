require "omniauth-oauth2"

module OmniAuth
  module Strategies
    # Authorization strategy for Rocket Chat using OAuth2.
    #
    # Allows your custom application to integrate with Rocket Chat through their
    # "Third-party login" feature. See: https://docs.rocket.chat/docs/third-party-login
    # for more information.
    #
    # To use it, you'll need to register your application with your Rocket Chat
    # instance and get a client ID and secret on the admin page, e.g.
    # https://example.com/admin/third-party-login
    #
    # @example Basic Usage
    #   use OmniAuth::Builder do
    #     provider :rocketchat,
    #              ENV["ROCKETCHAT_CLIENT_ID"],
    #              ENV["ROCKETCHAT_CLIENT_SECRET"],
    #              client_options: {
    #                site: "https://example.com"
    #              }
    #   end
    #
    # @example Basic Usage with Custom Endpoints
    #   use OmniAuth::Builder do
    #     provider :rocketchat,
    #              ENV["ROCKETCHAT_CLIENT_ID"],
    #              ENV["ROCKETCHAT_CLIENT_SECRET"],
    #              client_options: {
    #                site: "https://example.com",
    #                authorize_url: "/custom/oauth/authorize",
    #                token_url: "/custom/oauth/token"
    #              }
    #   end
    #
    # @example Basic Usage with Rails
    #   # /config/initializers/rocketchat.rb
    #   Rails.application.config.middleware.use OmniAuth::Builder do
    #     provider :rocketchat,
    #              ENV["ROCKETCHAT_CLIENT_ID"],
    #              ENV["ROCKETCHAT_CLIENT_SECRET"],
    #              client_options: {
    #                site: "https://example.com"
    #              }
    #   end
    #
    # @example Basic Usage with Devise
    #   # /config/initializers/devise.rb
    #   Devise.setup do |config|
    #     config.omniauth :rocketchat,
    #                     ENV["ROCKETCHAT_CLIENT_ID"],
    #                     ENV["ROCKETCHAT_CLIENT_SECRET"],
    #                     client_options: {
    #                       site: "https://example.com"
    #                     }
    #   end
    class RocketChat < OmniAuth::Strategies::OAuth2
      DEFAULT_AUTHORIZE_URL = "/oauth/authorize"
      DEFAULT_TOKEN_URL = "/oauth/token"

      option :name, "rocketchat"

      option :client_options, {
        authorize_url: DEFAULT_AUTHORIZE_URL,
        token_url: DEFAULT_TOKEN_URL
      }

      # You may specify that your strategy should use PKCE by setting
      # the pkce option to true: https://tools.ietf.org/html/rfc7636
      option :pkce, true

      uid do
        raw_info["_id"]
      end

      # Most commonly used info from the +/api/v1/me+ endpoint.
      #
      # +info.email+ returns +nil+ if the user has no confirmed email address.
      # If email confirmation is disabled on the Rocket Chat instance, the email
      # will never be confirmed.
      #
      # You may want to handle the +extra.raw_info.emails+ array in this case.
      # It contains all email addresses associated with the user. Confirmed and
      # unconfirmed.
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
