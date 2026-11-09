# frozen_string_literal: true

module TendrilTasks
  # Gustwave::Breadcrumb with the app's home link. Long titles are cut off
  # rather than wrapped, so the breadcrumb stays on one line on small screens.
  #
  # Call +with_home+ first, as items render in the order they're set.
  #
  # === Example
  #
  #   <%= render TendrilTasks::Breadcrumb.new do |breadcrumb| %>
  #     <% breadcrumb.with_home %>
  #     <% breadcrumb.with_item "Section", href: section_path %>
  #     <% breadcrumb.with_item "Subsection" %>
  #   <% end %>
  class Breadcrumb < TendrilTasks::Component
    delegate :with_item, to: :@breadcrumb

    # @param list_options [Hash] HTML attributes for the +ol+ element.
    # @param options [Hash] the arguments of Gustwave::Breadcrumb, e.g. HTML attributes for the +nav+ element.
    def initialize(list_options: {}, **options)
      @breadcrumb = Gustwave::Breadcrumb.new(
        list_options: configure_html_attributes(list_options, class: "truncate"),
        **options
      )
    end

    # Adds the link to the home page.
    #
    # @param title [String, nil] the title of the link (default: the home title in the current locale)
    # @param href [String] the URL of the link (default: root_path)
    # @param icon [Symbol] the icon of the link (default: :home)
    def with_home(title = nil, href: root_path, icon: :home)
      @breadcrumb.with_item(title || t(".home"), href:, icon:)
    end

    def call
      content
      render @breadcrumb
    end
  end
end
