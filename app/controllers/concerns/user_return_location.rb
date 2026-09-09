# frozen_string_literal: true

# Stores the user's return location for post-authentication redirects.
#
# When an unauthenticated user attempts to access a protected resource, they are
# redirected to the login page. After successful authentication, the user should
# be redirected back to the originally requested resource for improved user
# experience.
#
# This concern records the last accessed resource to enable this behavior using
# devise functionality.
module UserReturnLocation
  extend ActiveSupport::Concern

  class InfiniteRedirectError < StandardError; end

  included do
    before_action :store_user_return_location, if: :storable_location?
  end

  class_methods do
    def return_location_storage_disabled?
      @_skip_return_location_storage
    end

    private

    # Skips storing the user's return location for all requests on this
    # controller.
    def skip_return_location_storage
      @_skip_return_location_storage = true
    end
  end

  private

  def store_user_return_location
    store_location_for(:user, request.fullpath)
  end

  # Determines whether the current location can be safely stored for a
  # post-authentication redirect.
  #
  # @return [Boolean]
  def storable_location?
    request.get? &&
      !self.class.return_location_storage_disabled? &&
      is_navigational_format? &&
      !devise_controller? &&
      !request.xhr?
  end

  # Redirects the user to the stored location or to the default path if no
  # location is stored.
  #
  # Raises an error instead of redirecting when the resolved destination is the
  # current request location, preventing an infinite redirect loop.
  #
  # @param fallback [String] The default path to redirect to if no location is stored. Default: `root_path`.
  # @raise [InfiniteRedirectError] If the redirect destination is the current request location.
  def redirect_to_stored_location(fallback: root_path)
    redirect_location = stored_location_for(:user) || fallback

    if redirect_location == request.fullpath
      raise InfiniteRedirectError, "Cannot redirect to the current location: #{request.fullpath}"
    end

    redirect_to redirect_location
  end
end
