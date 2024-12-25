module Gustwave
  module Previews
    class BadgePreview < ViewComponent::Preview
      # http://localhost:3030/rails/view_components/gustwave/previews/badge/with_text_block
      def with_text_parameter
        render Gustwave::Badge.new("Default")
      end

      def with_text_block
        render Gustwave::Badge.new do
          "Default"
        end
      end

      def with_scheme
        render Gustwave::Badge.new("Red", scheme: :red)
      end

      def large
        render Gustwave::Badge.new("Default", size: :lg)
      end

      def bordered
        render Gustwave::Badge.new("Default", border: true)
      end

      def pill
        render Gustwave::Badge.new("Default", pill: true)
      end

      def as_link
        render Gustwave::Badge.new("Default", tag: :a, href: "#")
      end

      def with_icon_and_text
        # TODO implement as slots `leading_svg` and `trailing_svg`
        icon = <<~SVG
          <svg class="w-2.5 h-2.5 me-1" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 20 20">
            <path d="M10 0a10 10 0 1 0 10 10A10.011 10.011 0 0 0 10 0Zm3.982 13.982a1 1 0 0 1-1.414 0l-3.274-3.274A1.012 1.012 0 0 1 9 10V6a1 1 0 0 1 2 0v3.586l2.982 2.982a1 1 0 0 1 0 1.414Z"/>
          </svg>
          2 minutes ago
        SVG
        render Gustwave::Badge.new(class: "inline-flex items-center", border: true) do
          icon.html_safe
        end
      end

      def with_icon
        # TODO implement as a separate component with composition
        icon = <<~SVG
          <svg class="w-3 h-3" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 20 20">
            <path fill="currentColor" d="m18.774 8.245-.892-.893a1.5 1.5 0 0 1-.437-1.052V5.036a2.484 2.484 0 0 0-2.48-2.48H13.7a1.5 1.5 0 0 1-1.052-.438l-.893-.892a2.484 2.484 0 0 0-3.51 0l-.893.892a1.5 1.5 0 0 1-1.052.437H5.036a2.484 2.484 0 0 0-2.48 2.481V6.3a1.5 1.5 0 0 1-.438 1.052l-.892.893a2.484 2.484 0 0 0 0 3.51l.892.893a1.5 1.5 0 0 1 .437 1.052v1.264a2.484 2.484 0 0 0 2.481 2.481H6.3a1.5 1.5 0 0 1 1.052.437l.893.892a2.484 2.484 0 0 0 3.51 0l.893-.892a1.5 1.5 0 0 1 1.052-.437h1.264a2.484 2.484 0 0 0 2.481-2.48V13.7a1.5 1.5 0 0 1 .437-1.052l.892-.893a2.484 2.484 0 0 0 0-3.51Z"/>
            <path fill="#fff" d="M8 13a1 1 0 0 1-.707-.293l-2-2a1 1 0 1 1 1.414-1.414l1.42 1.42 5.318-3.545a1 1 0 0 1 1.11 1.664l-6 4A1 1 0 0 1 8 13Z"/>
          </svg>
          <span class="sr-only">Icon description</span>
        SVG
        render Gustwave::Badge.new(class: "inline-flex items-center justify-center w-6 h-6 rounded-full p-0", scheme: :red) do
          icon.html_safe
        end
      end

      def dismissible
        # TODO The dismiss cross renders too small, fix later
        dismiss_button = <<~HTML
          Default
          <button type="button" class="inline-flex items-center p-1 ms-2 text-sm text-indigo-400 bg-transparent rounded-sm hover:bg-indigo-200 hover:text-indigo-900 dark:hover:bg-indigo-800 dark:hover:text-indigo-300" data-dismiss-target="#badge-dismiss-default" aria-label="Remove">
            <svg class="w-2 h-2" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 14 14">
              <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 1 6 6m0 0 6 6M7 7l6-6M7 7l-6 6"/>
            </svg>
            <span class="sr-only">Remove badge</span>
          </button>
        HTML

        render Gustwave::Badge.new(id: "badge-dismiss-default",
                                   class: "inline-flex items-center justify-center px-2 py-1 text-sm font-medium text-indigo-800 bg-indigo-100 rounded dark:bg-indigo-900 dark:text-indigo-300",
                                   scheme: :none) do
          dismiss_button.html_safe
        end
      end
    end
  end
end
