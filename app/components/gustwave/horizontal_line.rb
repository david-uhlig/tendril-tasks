# frozen_string_literal: true

module Gustwave
  # Use HorizontalLine to separate sections of content with a horizontal line.
  #
  # Examples:
  #
  # Renders a thin gray horizontal line
  #
  #   <%= render Gustwave::HorizontalLine.new %>
  #
  # You can pass HTML attributes to the +<hr>+ element and your css classes
  # will be merged with the default classes without style conflicts:
  #
  #   <%= render Gustwave::HorizontalLine.new(class: "border-t-2 border-gray-300") %>
  #
  # Customize the appearance of the line by passing a scheme:
  #
  #   <%= render Gustwave::HorizontalLine.new(scheme: :trimmed) %>
  #
  # Reset all styles by passing the +none+ scheme:
  #
  #   <%= render Gustwave::HorizontalLine.new(scheme: :none) %>
  #
  # You can render text in the middle of the line by passing a block or using
  # the +with_content+ method:
  #
  #   <%= render Gustwave::HorizontalLine.new.with_content("Hello!") %>
  #
  #   <%= render Gustwave::HorizontalLine.new do |component| %>
  #    Hello!
  #   <% end %>
  #
  # You can also use the text slot if you want to modify the styling of the
  # enclosing span element:
  #
  #   <%= render Gustwave::HorizontalLine.new do |component| %>
  #     <% component.text "Hello!", class: "text-lg font-bold" %>
  #   <% end %>
  #
  # In the same way, you can render an SVG element in the middle of the line
  # enclosed by a div element:
  #
  #  <%= render Gustwave::HorizontalLine.new do |component| %>
  #   <% component.svg(class: "w-6 h-6") do %>
  #     <svg width="300" height="170" xmlns="http://www.w3.org/2000/svg">
  #       <rect width="150" height="150" x="10" y="10" rx="20" ry="20" style="fill:red;stroke:black;stroke-width:5;opacity:0.5">
  #     </svg>
  #   <% end %>
  #  <% end %>
  #
  class HorizontalLine < Gustwave::Component
    DEFAULT_SCHEME = :default
    SCHEME_MAPPINGS = {
      none: "",
      default: "mx-auto border-0 rounded w-full h-px my-8 bg-gray-200 dark:bg-gray-700",
      trimmed: "mx-auto border-0 rounded w-48 h-1 my-4 bg-gray-100 md:my-10 dark:bg-gray-700",
      squared: "mx-auto border-0 rounded w-8 h-8 my-8 bg-gray-200 md:my-12 dark:bg-gray-700"
    }
    SCHEME_OPTIONS = SCHEME_MAPPINGS.keys

    DEFAULT_VISUAL_TEXT_CLASSES = "absolute px-3 font-medium text-gray-900 -translate-x-1/2 bg-white left-1/2 dark:text-white dark:bg-gray-900"
    DEFAULT_VISUAL_SVG_CLASSES = "absolute px-4 -translate-x-1/2 bg-white left-1/2 dark:bg-gray-900"
    CONTENT_TEXT_CLASSES = DEFAULT_VISUAL_TEXT_CLASSES
    CONTENT_BLOCK_CLASSES = "absolute px-4 -translate-x-1/2 bg-white left-1/2 dark:bg-gray-900"

    renders_one :visual, types: {
      text: ->(text, **options) {
        options.deep_symbolize_keys!
        options[:class] = class_merge(
          DEFAULT_VISUAL_TEXT_CLASSES,
          options.delete(:class)
        )
        tag.span(text, **options)
      },
      svg: ->(**options, &block) {
        options = normalize_keys(options)
        options[:class] = class_merge(
          DEFAULT_VISUAL_SVG_CLASSES,
          options.delete(:class)
        )
        options[:"aria-hidden"] = options.delete(:"aria-hidden") || "true"

        tag.div(block.call, **options)
      }
    }
    alias text with_visual_text
    alias svg with_visual_svg

    # Initializes a new HorizontalLine component.
    #
    # @param scheme [Symbol] the scheme to be used for styling the horizontal line.
    # @param options [Hash] additional HTML options to be applied to the +<hr>+ element.
    def initialize(scheme: DEFAULT_SCHEME, **options)
      @scheme = fetch_or_fallback(SCHEME_OPTIONS, scheme, DEFAULT_SCHEME)
      @options = build_options(options)
    end

    # Renders the horizontal line `<hr>` with the specified options.
    #
    # @return [String] the HTML string for the `<hr>` element.
    def call
      return tag.hr(**@options) unless content.present? || visual?

      visual_or_content = case
                          # SVG and text already have enclosing elements
                          when visual?
                            visual
                          # Everything besides pure text
                          when content.is_a?(ActiveSupport::SafeBuffer)
                            tag.div(class: CONTENT_BLOCK_CLASSES) do
                              content
                            end
                          # Pure text
                          else
                            tag.span(content, class: CONTENT_TEXT_CLASSES) do
                              content
                            end
                          end

      tag.div(class: "inline-flex items-center justify-center w-full") do
        concat tag.hr(**@options)
        concat visual_or_content
      end
    end

    private

    # Builds the options hash for the `<hr>` element, merging the scheme's CSS classes.
    #
    # @param options [Hash] the initial options hash.
    # @return [Hash] the modified options hash with the scheme's CSS classes.
    def build_options(options)
      options.deep_symbolize_keys!
      options[:class] = class_merge(SCHEME_MAPPINGS[@scheme], options.delete(:class))
      options
    end
  end
end
