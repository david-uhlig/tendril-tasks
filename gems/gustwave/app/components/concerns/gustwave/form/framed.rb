# frozen_string_literal: true

module Gustwave
  module Form
    # Flowbite's frame around a text editor: a bordered box with the editor in
    # a white body, and a bar above it, below it or both, as in Flowbite's
    # "WYSIWYG Editor" and "Comment box" textarea examples.
    #
    # Gustwave::Form::Textarea and Gustwave::Form::RichTextarea include the
    # concern. It holds the frame, so every control with one shares it. A
    # control that includes it
    #
    # * declares a +validation+ variant, which the frame's border follows,
    # * takes +frame_options:+, +header_options:+, +body_options:+ and
    #   +footer_options:+ and hands them to +frame_part_options+,
    # * calls +select_frame+ in +before_render+, once its slots are known,
    # * and wraps its element with +render_frame+.
    module Framed
      extend ActiveSupport::Concern

      # The frame's border per validation state. Flowbite shows no framed
      # validation state, so the colors are the input field's borders.
      FRAME_LOOK = {
        none: "border-gray-200 dark:border-gray-600",
        success: "border-green-500 dark:border-green-500",
        error: "border-red-500 dark:border-red-500"
      }.freeze

      # The value of the +bars+ variant for whether there is a header and
      # whether there is a footer
      BARS = {
        [ true, true ] => :both,
        [ true, false ] => :header,
        [ false, true ] => :footer,
        [ false, false ] => :none
      }.freeze

      included do
        # The box around the bars and the body
        part :frame, "w-full border rounded-lg bg-gray-50 dark:bg-gray-700"

        # The bar above the body
        part :header, "flex items-center justify-between px-3 py-2 border-b border-gray-200 dark:border-gray-600"

        # The white area that holds the form element
        part :body, "px-4 py-2 bg-white dark:bg-gray-800"

        # The bar below the body
        part :footer, "flex items-center justify-between px-3 py-2 border-t border-gray-200 dark:border-gray-600"

        # Set when the control renders in the frame
        toggle :framed, part: :frame, per: :validation, internal: true, values: FRAME_LOOK

        # Which bars the frame has. The body rounds the corners no bar covers.
        variant :bars, part: :body, default: :none, internal: true, values: {
          none: "rounded-lg",
          header: "rounded-b-lg",
          footer: "rounded-t-lg",
          both: ""
        }
      end

      private

      # Keeps the HTML attributes of the frame's parts.
      def frame_part_options(frame: {}, header: {}, body: {}, footer: {})
        @frame_part_options = { frame:, header:, body:, footer: }.transform_values { |options| (options || {}).to_h }
      end

      # Selects the frame's options. Call it in +before_render+, after
      # +content+, when the slots are known.
      #
      # @param header [Boolean] whether there is a header.
      # @param footer [Boolean] whether there is a footer.
      # @param framed [Boolean] whether the control renders in the frame. By default with a header or a footer.
      def select_frame(header:, footer:, framed: header || footer)
        bars = BARS.fetch([ header.present?, footer.present? ])
        @framed = framed ? true : false
        select_options(framed: @framed, bars:)
      end

      def framed? = @framed == true

      # Renders the frame around the block, which returns the form element.
      #
      # @param header [String, nil] the content of the header bar.
      # @param footer [String, nil] the content of the footer bar.
      def render_frame(header: nil, footer: nil, &block)
        tag.div(**frame_attributes(:frame)) do
          safe_join([
            (tag.div(header, **frame_attributes(:header)) if header),
            tag.div(**frame_attributes(:body), &block),
            (tag.div(footer, **frame_attributes(:footer)) if footer)
          ].compact)
        end
      end

      def frame_attributes(part)
        attributes_for(part, (@frame_part_options || {}).fetch(part, {}))
      end
    end
  end
end
