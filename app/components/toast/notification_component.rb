# frozen_string_literal: true

module Toast
  class NotificationComponent < TendrilTasks::Component
    DEFAULT_TYPE = :success
    TYPE_STATUS_MAPPINGS = {
      timedout: :warning # Issued by devise
    }.freeze
    TYPE_STATUS_OPTIONS = TYPE_STATUS_MAPPINGS.keys

    def initialize(message = nil, type: DEFAULT_TYPE)
      @message = message
      @type = type
    end

    def call
      render Gustwave::IconToast.new(@message, status: status_from_type, auto_remove: true)
    end

    private

    def status_from_type
      type = @type.to_sym
      return TYPE_STATUS_MAPPINGS[type] if TYPE_STATUS_MAPPINGS.key?(type)

      type
    end
  end
end
