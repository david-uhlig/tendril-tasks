# frozen_string_literal: true

class Modal::DialogComponent < TendrilTasks::Component
  attr_reader :id


  # The heading's text, rendered by Modal::ShellComponent
  renders_one :heading, ->(text) { text }

  renders_many :buttons, ->(**options) {
    Gustwave::Button.for(options[:theme]).new(**Gustwave::Modal.trigger_options(id, action: :hide), **options.except(:theme)) do
      content
    end
  }

  def initialize(id)
    @id = id
  end
end
