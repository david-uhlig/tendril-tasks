# frozen_string_literal: true

module Toast
  class NotificationComponent < TendrilTasks::Component
    DEFAULT_TYPE = :success
    TYPE_SCHEME_MAPPINGS = {
      timedout: :warning # Issued by devise
    }.freeze
    TYPE_SCHEME_OPTIONS = TYPE_SCHEME_MAPPINGS.keys

    def initialize(message = nil, type: DEFAULT_TYPE)
      @message = message
      # TODO type has no effect yet, implement other types
      @type = type
    end

    def call
      render Gustwave::IconToast.new(@message, scheme: scheme_from_type)
    end

    private

    def scheme_from_type
      type = @type.to_sym
      return TYPE_SCHEME_MAPPINGS[type] if TYPE_SCHEME_MAPPINGS.key?(type)

      type
    end
  end
end
