# frozen_string_literal: true

module Toast
  class NotificationComponent < ApplicationComponent
    DEFAULT_TYPE = :success

    def initialize(message = nil, type: DEFAULT_TYPE)
      @message = message
      # TODO type has no effect yet, implement other types
      @type = type
    end
  end
end
