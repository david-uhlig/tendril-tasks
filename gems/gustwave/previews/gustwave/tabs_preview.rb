module Gustwave
  class TabsPreview < ViewComponent::Preview
    # Link tabs, for navigation. Only the tab given +selected: true+ is current.
    def default
      render_with_template
    end

    def underline
      render_with_template
    end

    def pills
      render_with_template
    end

    def full_width
      render_with_template
    end

    def with_icons
      render_with_template
    end

    # Button tabs with panels, stacked beside them.
    def vertical
      render_with_template
    end

    # Button tabs with panels. Flowbite's JS shows the panel of the selected tab.
    # @param style select { choices: [default, underline, pills, full_width] }
    # @param vertical toggle
    def interactive(style: :underline, vertical: false)
      render_with_template(locals: { style: style.to_sym, vertical: })
    end

    # +active_class+ and +inactive_class+ replace the classes of the selected and
    # unselected tabs, here purple instead of blue.
    def active_tab_style
      render_with_template
    end
  end
end
