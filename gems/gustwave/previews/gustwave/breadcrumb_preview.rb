module Gustwave
  class BreadcrumbPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/breadcrumb/default
    # Flowbite's default breadcrumb: a home icon, a link and the current page.
    def default
      render Gustwave::Breadcrumb.new do |breadcrumb|
        breadcrumb.with_item("Home", href: "#", icon: :home)
        breadcrumb.with_item("Projects", href: "#")
        breadcrumb.with_item("Flowbite")
      end
    end

    # http://localhost:3030/rails/view_components/gustwave/breadcrumb/solid
    # The same breadcrumb on a bordered, solid background.
    def solid
      render Gustwave::Breadcrumb.new(solid: true) do |breadcrumb|
        breadcrumb.with_item("Home", href: "#", icon: :home)
        breadcrumb.with_item("Templates", href: "#")
        breadcrumb.with_item("Flowbite")
      end
    end

    # http://localhost:3030/rails/view_components/gustwave/breadcrumb/header
    # A breadcrumb with a dropdown on the right, next to a branch and an issue.
    def header
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/breadcrumb/dropdown
    # Items with dropdowns in place of their text, separated by slashes.
    def dropdown
      render_with_template
    end
  end
end
