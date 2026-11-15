module Gustwave
  module Form
    class ValidationMessagePreview < ViewComponent::Preview
      # A sample record for the bound scenarios, so they don't depend on a host app's models.
      class SampleSettings
        include ActiveModel::Model
        include ActiveModel::Attributes

        attribute :channels, default: -> { [] }

        validate { errors.add(:channels, "pick at least one channel") if channels.blank? }
      end

      # Not a Flowbite example, the message is a part of Flowbite's form fields. The message on its own, without a
      # validation state: it looks like a helper text. The block is the message.
      def default
        render_with_template
      end

      # Not a Flowbite example. The message in the success and the error state, with a bold lead-in as in Flowbite's
      # validation examples.
      def validation
        render_with_template
      end

      # Not a Flowbite example. A message for a group that isn't a Gustwave::Form::Fieldset: a +<fieldset>+ of the
      # caller's own, with the checkboxes of a +multiple+ attribute. The message renders the attribute's error
      # sentence once, in the error state, under the ID the fieldset's +aria-describedby+ names.
      def in_own_fieldset
        settings = SampleSettings.new
        settings.validate
        render_with_template(locals: { settings: settings })
      end

      # Not a Flowbite example. A message without a form: it renders only the block, and the ID and the state are
      # up to the caller.
      def without_form
        render_with_template
      end

      # The message's options, for trying out how they combine.
      # @param validation select { choices: [none, success, error] }
      # @param text text
      def playground(validation: :error, text: "Choose a plan to continue.")
        render_with_template(locals: { validation: validation.to_sym, text: text })
      end
    end
  end
end
