# frozen_string_literal: true

module TendrilTasks
  class Avatar < ApplicationComponent
    DEFAULT_SCHEME = Gustwave::Avatar::DEFAULT_SCHEME
    DEFAULT_SIZE = Gustwave::Avatar::DEFAULT_SIZE

    def initialize(user, scheme: DEFAULT_SCHEME, size: DEFAULT_SIZE, border: false, **options)
      @src = user.avatar_url

      options ||= {}
      options[:scheme] ||= scheme
      options[:size] ||= size
      options[:border] ||= border

      @options = options
    end

    # Renders the avatar as an HTML <img> tag with the appropriate options.
    #
    # @return [String] HTML-safe string representing the <img> tag for the avatar.
    def call
      render Gustwave::Avatar.new(src: @src, **@options)
    end
  end
end
