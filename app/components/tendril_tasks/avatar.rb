# frozen_string_literal: true

module TendrilTasks
  class Avatar < TendrilTasks::Component
    with_collection_parameter :collection_item

    DEFAULT_SCHEME = :round
    DEFAULT_SIZE = :md

    def initialize(user = nil,
                   scheme: DEFAULT_SCHEME,
                   size: DEFAULT_SIZE,
                   border: false,
                   **options)
      user ||= options.delete(:collection_item)
      @src = user.avatar_url

      options.deep_symbolize_keys!
      kwargs = { scheme:, size:, border: }.compact
      @options = kwargs.merge!(options.except!(:collection_item))
    end

    # Renders the avatar as an HTML <img> tag with the appropriate options.
    #
    # @return [String] HTML-safe string representing the <img> tag for the avatar.
    def call
      render Gustwave::Avatar.new(src: @src, **@options)
    end
  end
end
