# frozen_string_literal: true

module Gustwave
  # Use Jumbotron for a hero section, the first section of a page with a
  # marketing message, as in Flowbite's jumbotrons. The section holds a
  # container with a maximum width. The content is a block: compose the
  # heading, text, buttons, media or form in it with the other components.
  #
  # The jumbotron has no slots for these parts. Pass the content as a block,
  # and HTML attributes for the section as options.
  #
  # Examples:
  #
  # Renders a centered hero with a heading, a paragraph and two buttons:
  #
  #   <%= render Gustwave::Jumbotron.new(centered: true) do %>
  #     <%= render Gustwave::Heading.new("We invest in the world’s potential", tag: :h1, size: :"2xl", responsive: true, class: "mb-4 tracking-tight leading-none") %>
  #     <%= render Gustwave::Paragraph.new("Here at Flowbite we focus on markets where technology, innovation, and capital can unlock long-term value.", class: "mb-8 text-lg font-normal lg:text-xl sm:px-16 lg:px-48") %>
  #     <div class="flex flex-col space-y-4 sm:flex-row sm:justify-center sm:space-y-0">
  #       <%= render Gustwave::Buttons::Default.new("Get started", tag: :a, href: "#", size: :lg) %>
  #       <%= render Gustwave::Buttons::Default.new("Learn more", tag: :a, href: "#", color: :alternative, size: :lg, class: "sm:ms-4") %>
  #     </div>
  #   <% end %>
  #
  # Lays the content out in two columns from the +lg+ breakpoint up, with
  # +container_options:+. Its classes win conflicts with the container's:
  #
  #   <%= render Gustwave::Jumbotron.new(container_options: { class: "grid lg:grid-cols-2 gap-8 lg:gap-16" }) do %>
  #     <div class="flex flex-col justify-center">
  #       <%= render Gustwave::Heading.new("Watch the keynote", tag: :h1, size: :"2xl", responsive: true, class: "mb-4") %>
  #     </div>
  #     <div>
  #       <iframe class="mx-auto w-full h-64 rounded-lg shadow-xl" src="https://www.youtube.com/embed/KaLxCiilHns" title="YouTube video player" allowfullscreen></iframe>
  #     </div>
  #   <% end %>
  #
  # Sets a background image behind the content with +with_background_image+.
  # It takes any image source +image_tag+ does, such as an asset path or an
  # Active Storage attachment, and HTML attributes for the +<img>+. The image
  # covers the section and is darkened by multiplying it with the section's
  # gray background; change the tint with +class:+ on the jumbotron. It's
  # decorative, so +alt+ defaults to +""+. A hero image is usually the
  # largest element on the page, so consider +fetchpriority: "high"+. The
  # text over it isn't recolored: give it light classes, e.g. +text-white+.
  # Add more padding with +container_options:+ for a taller hero:
  #
  #   <%= render Gustwave::Jumbotron.new(centered: true, container_options: { class: "py-24 lg:py-56" }) do |jumbotron| %>
  #     <% jumbotron.with_background_image("hero.jpg", fetchpriority: "high") %>
  #     <%= render Gustwave::Heading.new("We invest in the world’s potential", tag: :h1, size: :"2xl", responsive: true, class: "mb-4 text-white") %>
  #   <% end %>
  #
  # Covers the whole section with a decorative overlay. The overlay is a
  # block element placed behind the content. Give the section +relative
  # isolate+ so the overlay stays inside it:
  #
  #   <%= render Gustwave::Jumbotron.new(class: "relative isolate") do %>
  #     <div class="absolute inset-0 -z-10 bg-linear-to-b from-blue-50 to-transparent dark:from-blue-900"></div>
  #     <%= render Gustwave::Heading.new("We invest in the world’s potential", tag: :h1, size: :"2xl", responsive: true, class: "mb-4") %>
  #   <% end %>
  #
  # Spacing around the jumbotron is up to the caller, e.g. +class: "mb-4"+.
  # Caller classes win conflicts with the jumbotron's classes.
  #
  # @status alpha
  class Jumbotron < Gustwave::Component
    base "bg-white dark:bg-gray-900"

    part :container, "py-8 px-4 mx-auto max-w-screen-xl lg:py-16"

    part :background_image, "absolute inset-0 -z-10 size-full object-cover mix-blend-multiply"

    # Centers the content, as in Flowbite's default jumbotron
    toggle :centered, "text-center", part: :container

    # Set by the component: the section holds the background image and
    # darkens it with its gray background
    toggle :has_background_image, "relative isolate bg-gray-700 dark:bg-gray-700", internal: true

    # Renders an image behind the content, covering the section.
    #
    # @param src [String] the image source, passed to +image_tag+
    # @param alt [String] the alt text. Defaults to +""+, as the image is decorative.
    # @param options [Hash] additional HTML attributes for the image tag, e.g. +fetchpriority+ or +srcset+. Its classes win conflicts.
    renders_one_extensible :background_image, ->(src, alt: "", **options) {
      image_tag(src, alt:, **attributes_for(:background_image, options))
    }

    # @param centered [Boolean] Whether the content is centered. Defaults to +false+.
    # @param container_options [Hash] Additional HTML attributes for the container inside the section, e.g. +class+. Its classes win conflicts with the container's classes.
    # @param options [Hash] Additional HTML attributes passed to the +<section>+ element, e.g. +class+, +id+ or +style+.
    def initialize(centered: false, container_options: {}, **options)
      select_options(centered:)
      @options = options
      @container_options = attributes_for(:container, container_options)
    end

    def before_render
      # Must select here to know whether the background image slot was set
      select_options(has_background_image: background_image?)
      @config = attributes_for(@options)
    end

    def call
      tag.section(**@config) do
        safe_join([ background_image, tag.div(content, **@container_options) ].compact)
      end
    end
  end
end
