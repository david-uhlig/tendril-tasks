module Gustwave
  class ProgressPreview < ViewComponent::Preview
    # A bar filled to 45 percent. The track is labelled for screen readers.
    def default
      render Gustwave::Progress.new(45, aria: { label: "Task progress" })
    end

    # The four heights, with a label above each one.
    def sizes
      render_with_template
    end

    # The percentage inside the bar. The bar is as tall as its text, so the size doesn't apply.
    def label_inside
      render Gustwave::Progress.new(45, label: :inside, aria: { label: "Task progress" })
    end

    # The percentage above the track, with the block content as the title.
    def label_outside
      render(Gustwave::Progress.new(45, label: :outside)) { "Flowbite" }
    end

    # Each color of the bar, with a label in the matching color.
    def colors
      render_with_template
    end

    # @param value number
    # @param size select { choices: [sm, md, lg, xl] }
    # @param color select { choices: [blue, dark, red, green, yellow, indigo, purple] }
    # @param label select { choices: [none, inside, outside] }
    def playground(value: 45, size: :md, color: :blue, label: :none)
      render(Gustwave::Progress.new(value, size:, color:, label:, aria: { label: "Task progress" })) { "Flowbite" }
    end
  end
end
