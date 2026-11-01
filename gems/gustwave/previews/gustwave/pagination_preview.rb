module Gustwave
  class PaginationPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/pagination/default
    def default
      render Gustwave::Pagination.new do |pagination|
        pagination.with_previous_page(href: "#")
        pagination.with_page("1", href: "#")
        pagination.with_page("2", href: "#")
        pagination.with_page("3", href: "#", active: true)
        pagination.with_page("4", href: "#")
        pagination.with_page("5", href: "#")
        pagination.with_next_page(href: "#")
      end
    end

    # http://localhost:3030/rails/view_components/gustwave/pagination/medium
    def medium
      render Gustwave::Pagination.new(size: :md) do |pagination|
        pagination.with_previous_page(href: "#")
        pagination.with_page("1", href: "#")
        pagination.with_page("2", href: "#")
        pagination.with_page("3", href: "#", active: true)
        pagination.with_page("4", href: "#")
        pagination.with_page("5", href: "#")
        pagination.with_next_page(href: "#")
      end
    end

    # http://localhost:3030/rails/view_components/gustwave/pagination/icons
    def icons
      render Gustwave::Pagination.new do |pagination|
        pagination.with_previous_page(href: "#", icon_only: true)
        pagination.with_page("1", href: "#")
        pagination.with_page("2", href: "#")
        pagination.with_page("3", href: "#", active: true)
        pagination.with_page("4", href: "#")
        pagination.with_page("5", href: "#")
        pagination.with_next_page(href: "#", icon_only: true)
      end
    end

    # http://localhost:3030/rails/view_components/gustwave/pagination/first_page
    def first_page
      render Gustwave::Pagination.new do |pagination|
        pagination.with_page("1", href: "#", active: true)
        pagination.with_page("2", href: "#")
        pagination.with_page("3", href: "#")
        pagination.with_next_page(href: "#")
      end
    end

    # http://localhost:3030/rails/view_components/gustwave/pagination/previous_next
    def previous_next
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/pagination/previous_next_icons
    def previous_next_icons
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/pagination/table_data
    def table_data
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/pagination/table_data_icons
    def table_data_icons
      render_with_template
    end
  end
end
