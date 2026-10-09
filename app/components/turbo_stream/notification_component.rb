# frozen_string_literal: true

module TurboStream
  class NotificationComponent < TendrilTasks::Component
    CONTAINER_ID = "notifications"

    def initialize(message, scheme: :success)
      @message = message
      @scheme = scheme
    end

    def call
      turbo_stream.append CONTAINER_ID do
        render Gustwave::IconToast.new(@message, scheme: @scheme)
      end
    end
  end
end
