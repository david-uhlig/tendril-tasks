module Gustwave
  class TabsPreview < ViewComponent::Preview
    # http://localhost:3030/rails/view_components/gustwave/tabs/default
    #
    # Link tabs, for navigation. Only the tab given +selected: true+ is current.
    def default
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/tabs/underline
    def underline
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/tabs/pills
    def pills
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/tabs/full_width
    def full_width
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/tabs/with_icons
    def with_icons
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/tabs/vertical
    #
    # Button tabs with panels, stacked beside them.
    def vertical
      render_with_template
    end

    # http://localhost:3030/rails/view_components/gustwave/tabs/interactive
    #
    # Button tabs with panels. Flowbite's JS shows the panel of the selected tab.
    def interactive(style: :underline, vertical: false)
      render_with_template(locals: { style: style.to_sym, vertical: })
    end

    # http://localhost:3030/rails/view_components/gustwave/tabs/active_tab_style
    #
    # +active_class+ and +inactive_class+ replace the classes of the selected and
    # unselected tabs, here purple instead of blue.
    def active_tab_style
      render_with_template
    end
  end
end
