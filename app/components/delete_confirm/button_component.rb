# frozen_string_literal: true

module DeleteConfirm
  class ButtonComponent < TendrilTasks::Component
    attr_reader :target_modal_id

    def initialize(text:, target_modal_id: nil, **options)
      @text = text
      @target_modal_id = target_modal_id.presence || "delete-confirm-#{SecureRandom.alphanumeric(5)}"
      @options = build_options(options)
    end

    def call
      render ::ButtonComponent.new(**@options).with_content(@text)
    end

    private

    def build_options(options)
      options.deep_symbolize_keys!
      options[:scheme] ||= :red
      options[:size] ||= :large
      options[:class] ||= "w-full"
      options[:type] ||= :button
      options[:data] = { "modal-target": @target_modal_id, "modal-toggle": @target_modal_id }.merge(options.delete("data") || {})
      options
    end
  end
end
