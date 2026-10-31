# frozen_string_literal: true

# The footer of the app's modals: a grid with one column on small screens and
# +columns+ columns from +md+ up.
class Modal::FooterComponent < TendrilTasks::Component
  # @param columns [Integer] the number of columns from +md+ up. Defaults to 1.
  # @param options [Hash] HTML attributes for the footer, e.g. +class+.
  def initialize(columns: 1, **options)
    @columns = columns
    @class = options.delete(:class)
    @options = options
  end

  def call
    classes = class_merge("grid grid-cols-1 place-items-stretch gap-2", ("md:grid-cols-#{@columns}" if @columns > 1), @class)
    render(Gustwave::ModalFooter.new(**@options, class: classes)) { content }
  end
end
