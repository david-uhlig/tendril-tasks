module Gustwave
  class ToastPreview < ViewComponent::Preview
    def default(position: :none)
      render Gustwave::Toast.new("Your changes were saved.", position:)
    end

    def not_dismissible
      render Gustwave::Toast.new("Saving…", dismissible: false)
    end

    def with_icon
      render_with_template(locals: { statuses: Gustwave::IconToast.option_values(:status).excluding(:none) })
    end
  end
end
