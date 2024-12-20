# frozen_string_literal: true

require "tailwind_merge"

module TailwindHelper
  MERGER = TailwindMerge::Merger.new

  # Utility function to efficiently merge Tailwind CSS classes without style conflicts.
  # @see https://github.com/gjtorikian/tailwind_merge
  def class_merge(*args)
    MERGER.merge(args)
  end
end
