# frozen_string_literal: true

class Modal::DialogComponent < TendrilTasks::Component
  attr_reader :id


  # The heading's text, rendered by Modal::ShellComponent
  renders_one :heading, ->(text) { text }

  renders_many :buttons, ->(**options) {
    Gustwave::Button.for(options[:theme]).new(data: { "modal-hide": id }, **options.except(:theme)) do
      content
    end
  }

  def initialize(id)
    @id = id
  end

  private

  def dialog_buttons
    classes = class_merge(Modal::ShellComponent::FOOTER_CLASS, "md:grid-cols-#{buttons.size}")
    tag.div class: classes do
      buttons.each do |button|
        concat button
      end
    end
  end
end
