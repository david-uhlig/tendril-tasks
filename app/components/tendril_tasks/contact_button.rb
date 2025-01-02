# frozen_string_literal: true

module TendrilTasks
  class ContactButton < TendrilTasks::Component
    def initialize(user, is_responsive: true)
      @user = user
      @is_responsive = is_responsive
    end

    def responsive?
      @is_responsive
    end
  end
end
