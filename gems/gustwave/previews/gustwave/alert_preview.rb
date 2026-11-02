module Gustwave
  class AlertPreview < ViewComponent::Preview
    # The names Flowbite's examples give the colors
    NAMES = { blue: "Info", red: "Danger", green: "Success", yellow: "Warning", dark: "Dark" }.freeze

    def default
      render_with_template(locals: { colors: colors })
    end

    def with_icon
      render_with_template(locals: { colors: colors })
    end

    def bordered
      render_with_template(locals: { colors: colors })
    end

    def with_list
      render_with_template(locals: { colors: colors })
    end

    def dismissible
      render_with_template(locals: { colors: colors })
    end

    def border_accent
      render_with_template(locals: { colors: colors })
    end

    private

    # The colors and their names
    def colors
      Gustwave::Alert.option_values(:color).excluding(:none).index_with { NAMES.fetch(_1, _1.to_s.humanize) }
    end
  end
end
