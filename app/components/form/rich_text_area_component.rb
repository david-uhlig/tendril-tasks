# frozen_string_literal: true

module Form
  class RichTextAreaComponent < TendrilTasks::Component
    def initialize(form,
                   attribute,
                   label = nil,
                   disabled: [],
                   **options)
      @form = form
      @attribute = attribute
      @label = label

      @toolbar = {}
      @toolbar[:id] = random_id(prefix: "toolbar")

      @options = options
    end

    def disabled_buttons(*button_keys)
      @toolbar[:disabled] = button_keys.flatten
    end

    def hidden_buttons(*button_keys)
      @toolbar[:hidden] = button_keys.flatten
    end

    def before_render
      # Content must be called once to invoke the instance methods above
      content
    end

    def call
      render BaseFieldComponent.new(@form, @attribute, @label) do
        render Gustwave::Form::RichTextArea.new(@form,
                                                @attribute,
                                                toolbar_id: @toolbar[:id],
                                                sticky_toolbar: true,
                                                **@options) do |rich_text|
          rich_text.toolbar do
            render Gustwave::Form::RichText::Trix::Toolbar.new(@form, **@toolbar)
          end
        end
      end
    end
  end
end
