# frozen_string_literal: true

class ApplicationController < ActionController::Base
  include ToastNotificationsHelper, UserReturnLocation

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern if Rails.env.production?
  before_action :set_footer

  private

  def set_footer
    @footer = Footer::Data.new
  end
end
