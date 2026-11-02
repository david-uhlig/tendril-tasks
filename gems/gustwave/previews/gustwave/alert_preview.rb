module Gustwave
  class AlertPreview < ViewComponent::Preview
    # The names Flowbite's examples give the colors
    NAMES = { blue: "Info", red: "Danger", green: "Success", yellow: "Warning", dark: "Dark" }.freeze

    # Flowbite's buttons in alerts with additional content. Their colors aren't
    # a button theme, so they go through +color: :none+ and +size: :none+.
    BUTTON = "focus:ring-4 focus:outline-none font-medium rounded-lg text-xs px-3 py-1.5 text-center"
    PRIMARY_BUTTON = {
      blue: "text-white bg-blue-800 hover:bg-blue-900 focus:ring-blue-200 dark:bg-blue-600 dark:hover:bg-blue-700 dark:focus:ring-blue-800",
      red: "text-white bg-red-800 hover:bg-red-900 focus:ring-red-300 dark:bg-red-600 dark:hover:bg-red-700 dark:focus:ring-red-800",
      green: "text-white bg-green-800 hover:bg-green-900 focus:ring-green-300 dark:bg-green-600 dark:hover:bg-green-700 dark:focus:ring-green-800",
      yellow: "text-white bg-yellow-800 hover:bg-yellow-900 focus:ring-yellow-300 dark:bg-yellow-300 dark:text-gray-800 dark:hover:bg-yellow-400 dark:focus:ring-yellow-800",
      dark: "text-white bg-gray-700 hover:bg-gray-800 focus:ring-gray-300 dark:bg-gray-600 dark:hover:bg-gray-500 dark:focus:ring-gray-800"
    }.freeze
    SECONDARY_BUTTON = {
      blue: "text-blue-800 bg-transparent border border-blue-800 hover:bg-blue-900 hover:text-white focus:ring-blue-200 dark:hover:bg-blue-600 dark:border-blue-600 dark:text-blue-400 dark:hover:text-white dark:focus:ring-blue-800",
      red: "text-red-800 bg-transparent border border-red-800 hover:bg-red-900 hover:text-white focus:ring-red-300 dark:hover:bg-red-600 dark:border-red-600 dark:text-red-500 dark:hover:text-white dark:focus:ring-red-800",
      green: "text-green-800 bg-transparent border border-green-800 hover:bg-green-900 hover:text-white focus:ring-green-300 dark:hover:bg-green-600 dark:border-green-600 dark:text-green-400 dark:hover:text-white dark:focus:ring-green-800",
      yellow: "text-yellow-800 bg-transparent border border-yellow-800 hover:bg-yellow-900 hover:text-white focus:ring-yellow-300 dark:hover:bg-yellow-300 dark:border-yellow-300 dark:text-yellow-300 dark:hover:text-gray-800 dark:focus:ring-yellow-800",
      dark: "text-gray-800 bg-transparent border border-gray-700 hover:bg-gray-800 hover:text-white focus:ring-gray-300 dark:border-gray-600 dark:hover:bg-gray-600 dark:focus:ring-gray-800 dark:text-gray-300 dark:hover:text-white"
    }.freeze

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
      render_with_template(locals: { colors: colors.slice(:blue, :red) })
    end

    def dismissible
      render_with_template(locals: { colors: colors })
    end

    def border_accent
      render_with_template(locals: { colors: colors })
    end

    # Composed from the alert's block, because the icon and title sit above the
    # text here instead of beside it
    def additional_content
      render_with_template(locals: {
        colors: colors,
        primary_button: PRIMARY_BUTTON.transform_values { "#{BUTTON} me-2 inline-flex items-center #{_1}" },
        secondary_button: SECONDARY_BUTTON.transform_values { "#{BUTTON} #{_1}" }
      })
    end

    private

    # The colors and their names
    def colors
      Gustwave::Alert.option_values(:color).excluding(:none).index_with { NAMES.fetch(_1, _1.to_s.humanize) }
    end
  end
end
