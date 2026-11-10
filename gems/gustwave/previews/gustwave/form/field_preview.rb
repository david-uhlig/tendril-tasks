module Gustwave
  module Form
    class FieldPreview < ViewComponent::Preview
      # A sample record for the form scenarios, so they don't depend on a host app's models.
      class SampleTask
        include ActiveModel::Model
        include ActiveModel::Attributes

        attribute :title, :string
        attribute :contact, :string

        validates :title, presence: true
        validates :contact, format: { with: /@/, message: "must be an email address" }, allow_blank: true
      end

      # A form with Gustwave::FormBuilder on a record that has errors. The label, the input and the message show
      # the error state, and the message is the default error sentence, which the form builder takes from the
      # record. Rails' +field_with_errors+ wrapper is not added.
      def with_errors
        task = SampleTask.new(contact: "not-an-email")
        task.validate
        render_with_template(locals: { task: task })
      end

      # A field with +label: false+: no label is rendered, so the input needs an +aria-label+.
      def without_label
        render_with_template
      end

      # A field around the caller's own markup instead of a control: the field adds the label, helper text and
      # validation message, and the block is the control. Here it's a plain select.
      def custom_control
        render_with_template
      end
    end
  end
end
