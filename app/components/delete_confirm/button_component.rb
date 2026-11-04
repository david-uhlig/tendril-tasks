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
      render Gustwave::Button.for(@options[:theme]).new(**@options.except(:theme)).with_content(@text)
    end

    private

    def build_options(options)
      options.deep_symbolize_keys!
      options[:color] ||= :red
      options[:size] ||= :lg
      options[:class] ||= "w-full"
      options[:type] ||= :button
      # A stable id keeps Turbo's morph from reusing this toggle as another
      # button: Flowbite's click listener would survive and open the modal.
      options[:id] ||= "#{@target_modal_id}-toggle"
      options[:data] = options.delete(:data) || {}
      Gustwave::Modal.trigger_options(@target_modal_id, **options)
    end
  end
end
