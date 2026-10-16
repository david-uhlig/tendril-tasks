# frozen_string_literal: true

module TurboStream
  class NotificationComponent < TendrilTasks::Component
    CONTAINER_ID = "notifications"

    def initialize(message, status: :success)
      @message = message
      @status = status
    end

    def call
      turbo_stream.append CONTAINER_ID do
        render Gustwave::IconToast.new(@message, status: @status)
      end
    end
  end
end
