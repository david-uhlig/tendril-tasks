class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern if Rails.env.production?

  protected

  def access_denied_handler(exception)
    case exception.action
    when :index
      redirect_back_or_to root_path,
                          notice: "Bitte melde dich zunächst an.",
                          status: :found
    when :new, :create
      redirect_to exception.subject || root_path,
                  notice: "Das darfst du nicht!",
                  status: :found
    when :show, :edit, :update, :destroy
      # Don't expose whether a resource exists
      not_found!
    else
      not_found!
    end
  end

  def not_found!
    raise ActionController::RoutingError.new("Not Found")
  end
end
