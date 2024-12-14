# frozen_string_literal: true

class ContactButtonComponent < ApplicationComponent
  def initialize(user, is_responsive: true)
    @user = user
    @is_responsive = is_responsive
  end

  def responsive?
    @is_responsive
  end
end
