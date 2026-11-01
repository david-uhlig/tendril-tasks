# frozen_string_literal: true

module Gustwave
  # Use Pagination to move between pages of a list. It renders the joined list
  # of page links: it rounds the outer links, sets the same size on every link,
  # marks the current page with +aria-current="page"+, and labels the navigation
  # landmark.
  #
  # The component doesn't compute pages or build URLs. Pass each link its +href+,
  # e.g. from the list of pages your pagination library returns.
  #
  # Add a +previous_page+ and a +next_page+ slot for the arrows. Both are
  # optional: without a previous link, the first page link gets the start
  # rounding.
  #
  # === Example
  #
  # Renders a page navigation with the third page active:
  #
  #   <%= render Gustwave::Pagination.new do |pagination| %>
  #     <% pagination.with_previous_page(href: "/tasks?page=2") %>
  #     <% pagination.with_page("1", href: "/tasks?page=1") %>
  #     <% pagination.with_page("2", href: "/tasks?page=2") %>
  #     <% pagination.with_page("3", href: "/tasks?page=3", active: true) %>
  #     <% pagination.with_next_page(href: "/tasks?page=4", icon_only: true) %>
  #   <% end %>
  #
  # The slots always render in the order previous, pages, next, whatever order
  # they are set in.
  #
  # @see Gustwave::Pagination::Link
  class Pagination < Gustwave::Component
    part :list, "inline-flex -space-x-px"

    variant :size, part: :list, default: :sm, values: {
      sm: "text-sm",
      md: "text-base"
    }

    renders_one_extensible :previous_page, ->(text = nil, href:, icon_only: false, **options) {
      build_link(text, href:, icon: (:chevron_left if icon_only), **options)
    }

    renders_many_extensible :pages, ->(text = nil, href:, **options) {
      build_link(text, href:, **options)
    }

    renders_one_extensible :next_page, ->(text = nil, href:, icon_only: false, **options) {
      build_link(text, href:, icon: (:chevron_right if icon_only), **options)
    }

    # @param size [Symbol] +:sm+ (default) or +:md+, passed down to every link.
    # @param options [Hash] HTML attributes for the +nav+ element, e.g. +aria: { label: "Tasks" }+.
    def initialize(size: DEFAULT, **options)
      select_options(size:)
      @options = options
    end

    def before_render
      # t needs the view context, so this can't happen in the constructor
      @config = attributes_for(configure_html_attributes(@options, aria: { label: t(".label") }))
      previous_page&.apply_slot_context(default_text: t(".previous"))
      next_page&.apply_slot_context(default_text: t(".next"))
      links.each_with_index do |link, index|
        link.apply_slot_context(list_position: list_position(index))
      end
    end

    def call
      tag.nav(**@config) do
        tag.ul(class: classes(:list)) { safe_join(links.map { |link| tag.li { link.to_s } }) }
      end
    end

    private

    def links
      @links ||= [ previous_page, *pages, next_page ].compact
    end

    # :only for a single link, otherwise :first, :middle or :last
    def list_position(index)
      return :only if links.size == 1
      return :first if index.zero?
      return :last if index == links.size - 1

      :middle
    end

    # The slot's block reaches the link as its content, so the link doesn't set it again.
    def build_link(text, **options)
      Gustwave::Pagination::Link.new(text, size: option_value(:size), **options)
    end
  end
end
