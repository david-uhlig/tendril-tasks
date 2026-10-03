# frozen_string_literal: true

class Modal::DialogComponent < TendrilTasks::Component
  attr_reader :id


  # The heading's text, rendered by Modal::ShellComponent
  renders_one :heading_slot, ->(text) { text }
  alias heading with_heading_slot

  renders_many :buttons, ->(**options) {
    Gustwave::Button.new(data: { "modal-hide": id }, **options) do
      content
    end
  }
  alias button with_button

  def initialize(id, form_path: nil, form_method: :get)
    @id = id
    @form_path = form_path
    @form_method = form_method
  end

  private

  def dialog_buttons
    classes = class_merge(Modal::ShellComponent::FOOTER_CLASS, "md:grid-cols-#{buttons.size}")
    if @form_path.present?
      form_tag @form_path, method: @form_method, class: classes do
        buttons.each do |button|
          concat button
        end
      end
    else
      tag.div class: classes do
        buttons.each do |button|
          concat button
        end
      end
    end
  end
end
