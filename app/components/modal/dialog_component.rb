# frozen_string_literal: true

class Modal::DialogComponent < TendrilTasks::Component
  attr_reader :id

  DEFAULT_HEADER_CLASS = "text-xl font-semibold text-gray-900 dark:text-white"
  DEFAULT_FOOTER_CLASS = "grid grid-cols-1 place-items-stretch gap-2 p-4 md:p-5 border-t border-gray-200 rounded-b dark:border-gray-600"

  renders_one :heading_slot, ->(text) do
    tag.h3 class: DEFAULT_HEADER_CLASS do
      text
    end
  end
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
    classes = class_merge(DEFAULT_FOOTER_CLASS, "md:grid-cols-#{buttons.size}")
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
