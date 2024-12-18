# frozen_string_literal: true

module Modal
  class ToggleButtonComponent < ApplicationComponent
    attr_reader :modal_id

    def initialize(text = nil, modal_id:, **options)
      @text = text
      @modal_id = modal_id
      @options = build_options(options)
    end

    private

    def build_options(options)
      options.deep_symbolize_keys!
      options[:"data-modal-target"] = modal_id
      options[:"data-modal-toggle"] = modal_id
      options[:type] ||= :button
      options
    end
  end
end
