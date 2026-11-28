module Gustwave
  class ListPreview < ViewComponent::Preview
    # A list of password requirements, with a bullet before each item.
    def default
      render_with_template
    end

    # Requirements with a check icon, green when met and gray when not yet met.
    def icons
      render_with_template
    end

    # Three items, each with a numbered list of steps inside it.
    def nested_unordered
      render_with_template
    end

    # The password requirements without markers, for a list that needs none.
    def unstyled
      render_with_template
    end

    # A numbered list of the top volunteers and their hours.
    def ordered
      render_with_template
    end

    # Numbered steps, each with a bulleted list of points inside it.
    def nested_ordered
      render_with_template
    end

    # Items with check icons, some followed by a value in bold.
    def with_icons
      render_with_template
    end

    # Rows with an avatar, a name, an email and a price, separated by lines.
    def advanced_layout
      render_with_template
    end

    # Links in a centered row, without markers.
    def horizontal
      render_with_template
    end

    # Tune the list's tag, marker, color, orientation, nesting and dividers with the controls.
    # @param tag select { choices: [ul, ol] }
    # @param marker select { choices: [default, disc, decimal, none] }
    # @param color select { choices: [default, none] }
    # @param orientation select { choices: [vertical, horizontal] }
    # @param nested toggle
    # @param divided toggle
    def playground(tag: :ul, marker: :default, color: :default, orientation: :vertical, nested: false, divided: false)
      render_with_template(locals: { tag: tag.to_sym, marker: marker.to_sym, color: color.to_sym, orientation: orientation.to_sym, nested:, divided: })
    end
  end
end
