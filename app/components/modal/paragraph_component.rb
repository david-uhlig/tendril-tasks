# frozen_string_literal: true

# The body text of a modal, rendered with Gustwave::Paragraph.
class Modal::ParagraphComponent < TendrilTasks::Component
  base "text-base leading-relaxed"

  def initialize(text = nil, **options)
    @text = text
    @options = attributes_for(options)
  end

  def call
    render(Gustwave::Paragraph.new(text, **@options)) { content }
  end

  private

  attr_reader :text
end
