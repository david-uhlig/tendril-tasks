# frozen_string_literal: true

require "tailwind_merge"

module Gustwave
  # Merges Tailwind CSS classes for components. Gustwave::Component includes
  # it, and Gustwave::Styling merges a component's classes with MERGER.
  module TailwindHelper
    # The TailwindMerge merger that +class_merge+ and the components' class
    # merging use.
    MERGER = TailwindMerge::Merger.new

    # Utility function to efficiently merge Tailwind CSS classes without style conflicts.
    # @see https://github.com/gjtorikian/tailwind_merge
    #
    # @param args [Array<String, nil>] the class strings, in order. Where two classes set the same utility,
    #   the later one wins.
    # @return [String] the merged classes.
    def class_merge(*args)
      MERGER.merge(args)
    end
  end
end
