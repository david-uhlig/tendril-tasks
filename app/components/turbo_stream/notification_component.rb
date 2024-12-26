# frozen_string_literal: true

module TurboStream
  class NotificationComponent < TendrilTasks::Component
    CONTAINER_ID = "notifications"

    def initialize(message)
      @message = message
    end

    def call
      turbo_stream.append CONTAINER_ID do
        render Toast::NotificationComponent.new(@message)
      end
    end
  end
end
