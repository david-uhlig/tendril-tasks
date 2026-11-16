module Gustwave
  module Form
    class FieldsetPreview < ViewComponent::Preview
      # A sample record for the bound scenarios, so they don't depend on a host app's models.
      class SampleSettings
        include ActiveModel::Model
        include ActiveModel::Attributes

        attribute :channels, default: -> { [] }

        validate { errors.add(:channels, "pick at least one channel") if channels.blank? }
      end

      # A group of checkboxes with a legend and, under the group, a helper text. The fieldset's +aria-describedby+
      # names it.
      def default
        render_with_template
      end

      # The legend takes the validation state's colors, and the validation message and the helper text below the group
      # follow, in this order: none, success and error.
      def validation
        render_with_template
      end

      # A form with Gustwave::FormBuilder on a record with an error. The checkboxes of the +multiple+ attribute
      # are one field each and show the error state, and the fieldset renders the error sentence once, below the
      # group.
      def group_with_error
        settings = SampleSettings.new
        settings.validate
        render_with_template(locals: { settings: settings })
      end

      # A legend only for screen readers: the +label+ slot takes +class: "sr-only"+. The group still has its name, and
      # the page shows a heading of its own.
      def screen_reader_legend
        render_with_template
      end

      # A fieldset without a form: it renders only what the caller sets, so the message is set by hand and the
      # checkboxes are given their IDs.
      def without_form
        render_with_template
      end

      # The fieldset's options, for trying out how they combine.
      # @param validation select { choices: [none, success, error] }
      # @param helper_text text
      def playground(validation: :none, helper_text: "Pick the channels you want to hear from us on.")
        render_with_template(locals: { validation: validation.to_sym, helper_text: helper_text })
      end
    end
  end
end
