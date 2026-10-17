# frozen_string_literal: true

module Gustwave
  class Toast < Gustwave::Component
    base "flex items-center w-full max-w-xs p-4 text-gray-500 bg-white rounded-lg shadow-sm dark:text-gray-400 dark:bg-gray-800"

    variant :position, default: :none, values: {
      top_left: "fixed top-5 left-5",
      top_center: "fixed top-5 left-1/2 transform -translate-x-1/2",
      top_right: "fixed top-5 right-5",
      bottom_left: "fixed bottom-5 left-5",
      bottom_center: "fixed bottom-5 left-1/2 transform -translate-x-1/2",
      bottom_right: "fixed bottom-5 right-5"
    }

    CONTROLLER = "gustwave--animate-and-remove"
    AUTO_REMOVE_ACTIONS = %W[
      mouseover->#{CONTROLLER}#pause
      mouseout->#{CONTROLLER}#continue
    ].freeze

    # @param auto_remove [Boolean] Animates and removes the toast after a few
    #   seconds, pausing while hovered. Needs the Stimulus controller
    #   +gustwave--animate-and-remove+ that Gustwave ships. Off by default.
    def initialize(text = nil,
                   position: DEFAULT,
                   id: nil,
                   dismissible: true,
                   auto_remove: false,
                   **options)
      @text = text
      @id = id.presence || generate_random_id(prefix: "toast")
      @dismissible = ActiveModel::Type::Boolean.new.cast(dismissible) != false

      select_options(position:)
      options = options.deep_symbolize_keys
      options = merge_data_tokens(options, controller: CONTROLLER, action: AUTO_REMOVE_ACTIONS) if ActiveModel::Type::Boolean.new.cast(auto_remove)
      @options = attributes_for({ id: @id, role: "alert" }.merge(options))
    end

    def dismissible?
      @dismissible
    end

    private

    attr_reader :text

    # Adds Stimulus tokens to the data attributes, next to the caller's own.
    def merge_data_tokens(options, **tokens)
      data = (options[:data] || {}).symbolize_keys
      tokens.each do |name, added|
        data[name] = [ data[name], options.delete(:"data-#{name}"), *added ].flat_map { _1.to_s.split }.uniq.join(" ")
      end
      options.merge(data:)
    end
  end
end
