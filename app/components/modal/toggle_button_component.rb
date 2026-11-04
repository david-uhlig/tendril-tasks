# frozen_string_literal: true

module Modal
  class ToggleButtonComponent < TendrilTasks::Component
    attr_reader :modal_id

    def initialize(text = nil, modal_id:, **options)
      @text = text
      @modal_id = modal_id
      @options = build_options(options)
    end

    private

    def build_options(options)
      options = Gustwave::Modal.trigger_options(modal_id, **options.deep_symbolize_keys)
      options[:type] ||= :button
      options
    end
  end
end
