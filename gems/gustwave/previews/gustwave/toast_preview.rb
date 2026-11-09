module Gustwave
  class ToastPreview < ViewComponent::Preview
    # @param position select { choices: [none, top_left, top_center, top_right, bottom_left, bottom_center, bottom_right] }
    def default(position: :none)
      render Gustwave::Toast.new("Your changes were saved.", status: :info, position:)
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

    # The dismiss button customized with +with_dismiss_button+, nested in the layout.
    def custom_dismiss_button
      render_with_template
    end

    # Any visual in place of the status's icon: an icon in another theme, an
    # image, or a component.
    def custom_icon
      render_with_template
    end

    def not_dismissible
      render Gustwave::Toast.new("Saving…", dismissible: false)
    end

    # Every status, including the aliases for flash types.
    def with_icon
      render_with_template(locals: { statuses: Gustwave::Toast.option_values(:status).excluding(:none) })
    end
  end
end
