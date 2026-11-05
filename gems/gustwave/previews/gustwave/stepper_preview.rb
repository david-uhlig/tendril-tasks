module Gustwave
  class StepperPreview < ViewComponent::Preview
    # Numbered steps in a row. The first step is complete and shows a check icon in place of its number.
    def default
      render_with_template
    end

    # Icons in circles in a row. The first step is complete, and the text is for screen readers only.
    def progress
      render_with_template
    end

    # Numbered steps with a description under each title. The first step is the current one.
    def detailed
      render_with_template
    end

    # Boxes stacked one above the other. Completed steps are green, the current step is blue and the rest are gray.
    def vertical
      render_with_template
    end

    # Steps in a bordered bar with chevrons between them. The first step is the current one.
    def breadcrumb
      render_with_template
    end

    # A composition, not a stepper: a Gustwave::Timeline with markers for each step.
    def timeline
      render_with_template
    end

    # A progress stepper above a form, with the form fields as plain Tailwind markup.
    def with_form
      render_with_template
    end
  end
end
