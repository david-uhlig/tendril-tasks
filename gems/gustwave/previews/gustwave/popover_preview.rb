module Gustwave
  class PopoverPreview < ViewComponent::Preview
    # A person's details with a follow button.
    def user_profile; end

    # A company's details with links, people and actions.
    def company_profile; end

    # Text and an image side by side, opened from a link in a paragraph.
    def image; end

    # Longer help text, opened from an icon next to a label.
    def description; end

    # Spread +trigger_options+ into the triggering element.
    # @param placement select { choices: [auto, auto-start, auto-end, top, top-start, top-end, bottom, bottom-start, bottom-end, right, right-start, right-end, left, left-start, left-end] }
    # @param trigger_event select { choices: [hover, click] }
    def default(placement: :top, trigger_event: :hover)
      render_with_template(locals: { placement:, trigger_event: })
    end

    # Each placement on its own trigger.
    def placement; end

    # Opens on hover or on click.
    def triggering; end

    # Moves the popover further from its trigger.
    def offset; end

    # Fades in, through the transition every popover has.
    def animation; end

    # Leaves out the arrow.
    def no_arrow; end
  end
end
