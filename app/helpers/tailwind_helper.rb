# frozen_string_literal: true

require "tailwind_merge"

module TailwindHelper
  MERGER = TailwindMerge::Merger.new

  # Utility function to efficiently merge Tailwind CSS classes without style conflicts.
  # @see https://github.com/gjtorikian/tailwind_merge
  def class_merge(*args)
    MERGER.merge(args)
  end

  # Utility function to construct class names with optional prefix and postfix.
  #
  # Tailwind CSS doesn't support dynamic class names. It only detects classes
  # that appear somewhere in the source code. This helper function allows you
  # to construct class names dynamically to then paste them into your
  # application manually!
  # see: https://tailwindcss.com/docs/content-configuration#dynamic-class-names
  #
  # @param classes [String, Array<String>] The class names to be processed.
  # @param prefix [String, nil] An optional prefix to be added to each class name.
  # @param postfix [String, nil] An optional postfix to be added to each class name.
  # @return [String] The processed class names as a single string.
  def construct_class_names(classes, prefix: nil, postfix: nil)
    error_msg = <<~MSG
      This method cannot be used in production. Please do not use this method to
      generate class names dynamically. Tailwind CSS does not support dynamic#{' '}
      class names. See docs.
    MSG
    raise error_msg if Rails.env.production?

    Array(classes).flat_map { |c| c.split(" ") }
                  .map { |c| "#{prefix}#{c}#{postfix}" }
                  .join(" ")
  end
end
