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
      @avatar = user.avatar

      options.deep_symbolize_keys!
      kwargs = { scheme:, size:, border: }.compact
      @options = kwargs.merge!(options.except!(:collection_item))
    end

    # Renders the avatar stored by this app as an HTML <img> tag with the
    # appropriate options, or a placeholder until it has been downloaded.
    #
    # @return [String] HTML-safe string representing the avatar.
    def call
      if @avatar.attached?
        render Gustwave::Avatar.new(src: rails_storage_proxy_path(@avatar), **@options)
      else
        render Gustwave::AvatarPlaceholder.new(**@options)
      end
    end
  end
end
