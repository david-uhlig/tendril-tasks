module Gustwave
  class ToastPreview < ViewComponent::Preview
    # @param position select { choices: [none, top_left, top_center, top_right, bottom_left, bottom_center, bottom_right] }
    def default(position: :none)
      render Gustwave::IconToast.new("Your changes were saved.", position:)
    end

    def colors
      render_with_template
    end

    # A toast without a close button, with an icon set apart by a divider.
    def simple
      render_with_template
    end

    def undo
      render_with_template
    end

    def message
      render_with_template
    end

    def push
      render_with_template
    end

    def interactive
      render_with_template
    end

    def positioning
      render_with_template
    end

    def not_dismissible
      render Gustwave::Toast.new("Saving…", dismissible: false)
    end

    # Every status IconToast knows, including the aliases for flash types.
    def with_icon
      render_with_template(locals: { statuses: Gustwave::IconToast.option_values(:status).excluding(:none) })
    end
  end
end
