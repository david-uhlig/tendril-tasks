class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern if Rails.env.production?

  protected

  def access_denied_handler(exception)
    unless current_user.present?
      session[:redirect_back_to] = request.fullpath
      # Returning 302 is the de-facto standard for "user is unauthenticated"
      # redirects. Used by Google, Facebook, and Microsoft.
      # @see https://stackoverflow.com/a/72395961/9261925
      redirect_to new_user_session_path,
                 status: :found
      return
    end

    case exception.action
    when :index
      redirect_back_or_to root_path,
                          notice: "Bitte melde dich zunächst an.",
                          status: :found
    when :new, :create
      redirect_to exception.subject || root_path,
                  notice: "Das darfst du nicht!",
                  status: :found
      nil
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
