module Gustwave
  module Form
    class RichTextareaPreview < ViewComponent::Preview
      # A rich textarea in a field, with the default toolbar in the header.
      def default
        render_with_template
      end

      # The toolbar below the editor, with +with_footer_toolbar+.
      def footer_toolbar
        render_with_template
      end

      # A header toolbar without the table, the horizontal rule and file attachments.
      def reduced_toolbar
        render_with_template
      end

      # An editor without a toolbar: +toolbar: false+.
      def without_toolbar
        render_with_template
      end

      # The success and error look of the frame, each with a validation message. The looks follow the input
      # field's.
      def validation
        render_with_template
      end

      # The rich textarea's options, for trying out how they combine. @param validation
      # select { choices: [none, success, error] } @param sticky_toolbar toggle @param
      # toolbar_place select { choices: [header, footer] }
      def playground(validation: :none, sticky_toolbar: true, toolbar_place: :header)
        render_with_template(locals: {
          validation: validation.to_sym,
          sticky_toolbar: ActiveModel::Type::Boolean.new.cast(sticky_toolbar),
          toolbar_place: toolbar_place.to_sym
        })
      end
    end
  end
end
