# frozen_string_literal: true

module Gustwave
  # Use Card to group content in a bordered box, as in Flowbite's cards.
  #
  # The card renders a +<div>+, or an +<a>+ with +tag: :a+ and a +href+. A
  # card as a link gets a hover style. Pass the content as a block, and HTML
  # attributes for the root element as options.
  #
  # Examples:
  #
  # Renders a card with a block of content:
  #
  #   <%= render Gustwave::Card.new do %>
  #     <%= render Gustwave::Heading.new("Noteworthy technology", tag: :h5, class: "mb-2 tracking-tight") %>
  #     <%= render Gustwave::Paragraph.new("Here are the biggest enterprise technology acquisitions of 2021.") %>
  #   <% end %>
  #
  # Renders the whole card as a link:
  #
  #   <%= render Gustwave::Card.new(tag: :a, href: "/articles/1") do %>
  #     <%= render Gustwave::Paragraph.new("Read the article.") %>
  #   <% end %>
  #
  # Adds an image above the body with +with_image+. The +alt+ text is
  # required; pass +""+ for a decorative image. The body pads less below an
  # image. Wrap the image in a link with +href+, but don't do that in a card
  # rendered as a link, because links can't nest:
  #
  #   <%= render Gustwave::Card.new do |card| %>
  #     <% card.with_image("/cards/hero.png", alt: "") %>
  #     <%= render Gustwave::Paragraph.new("A card with an image.") %>
  #   <% end %>
  #
  # Puts the image beside the body from the +md+ breakpoint up, with +horizontal+:
  #
  #   <%= render Gustwave::Card.new(tag: :a, href: "/articles/1", horizontal: true) do |card| %>
  #     <% card.with_image("/cards/hero.png", alt: "Article photo") %>
  #     <%= render Gustwave::Paragraph.new("A horizontal card.") %>
  #   <% end %>
  #
  # Adjusts the body's classes with +configure_body+, e.g. to drop its padding
  # for a composition that pads its own parts:
  #
  #   <%= render Gustwave::Card.new do |card| %>
  #     <% card.configure_body(class: "px-0 pb-10 pt-4") %>
  #     <%= render Gustwave::Paragraph.new("Padding on the sides is up to the content.") %>
  #   <% end %>
  #
  # Spacing around the card is up to the caller, e.g. +class: "mb-4"+. Caller
  # classes win conflicts with the card's classes, e.g. +class: "max-w-md"+
  # replaces the default +max-w-sm+.
  class Card < Gustwave::Component
    option :tag, default: :div, values: %i[div a]

    base "max-w-sm bg-white border border-gray-200 rounded-lg shadow-sm dark:bg-gray-800 dark:border-gray-700"

    part :body, "p-6"
    part :image, "rounded-t-lg"

    # Set by the component: a card rendered as a link
    toggle :link, "block hover:bg-gray-100 dark:hover:bg-gray-700", internal: true
    # Set by the component: a card with an image pads its body less
    toggle :has_image, { body: "p-5" }, internal: true
    # Image beside the body from md up; declared last so it wins over :link's
    # `block` and :has_image's `p-5`
    toggle :horizontal, {
      root: "flex flex-col items-center max-w-none md:flex-row md:max-w-xl",
      image: "object-cover w-full h-96 md:h-auto md:w-48 md:rounded-none md:rounded-s-lg",
      body: "flex flex-col justify-between p-4 leading-normal"
    }

    # Renders an image above the body, or beside it when +horizontal+.
    #
    # @param src [String] the image source, passed to +image_tag+
    # @param alt [String] the alt text; pass "" for a decorative image
    # @param href [String, nil] wraps the image in a link. Don't use it in a card
    #   rendered as a link (tag: :a): links can't nest.
    # @param options [Hash] additional HTML attributes for the image tag
    renders_one_extensible :image, ->(src, alt:, href: nil, **options) {
      img = image_tag(src, alt:, **attributes_for(:image, options))
      href ? link_to(img, href) : img
    }

    # @param tag [Symbol] The HTML tag of the card. Defaults to :div. Use :a with an +href+ to render the whole card as a link.
    # @param horizontal [Boolean] Whether the image sits beside the body from the +md+ breakpoint up. Defaults to +false+.
    # @param options [Hash] Additional HTML attributes passed to the root element, e.g. +href+, +id+ or +class+.
    def initialize(tag: DEFAULT, horizontal: false, **options)
      select_options(tag:, horizontal:)
      select_options(link: option_value(:tag) == :a)
      @options = options
      @body_options = {}
    end

    # @param options [Hash] Additional HTML attributes for the body element, e.g. +class+.
    def configure_body(**options)
      @body_options = options
    end

    def before_render
      # Must select here to know whether the image slot was set
      select_options(has_image: image?)
      @config = attributes_for(@options)
      @body_config = attributes_for(:body, @body_options)
    end

    def call
      content_tag option_value(:tag), **@config do
        safe_join([ image, body ].compact)
      end
    end

    private
    attr_reader :config, :body_config

    def body
      tag.div(content, **body_config) if content.present?
    end
  end
end
