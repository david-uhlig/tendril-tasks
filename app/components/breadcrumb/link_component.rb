# frozen_string_literal: true

module Breadcrumb
  class LinkComponent < ApplicationComponent
    LINK_CLASS = "text-sm font-medium text-gray-700 dark:text-gray-400 hover:text-blue-600 dark:hover:text-white"

    HOME_ICON = <<-HTML
      <svg class="w-3 h-3 me-2.5" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="currentColor" viewBox="0 0 20 20">
        <path d="m19.707 9.293-2-2-7-7a1 1 0 0 0-1.414 0l-7 7-2 2a1 1 0 0 0 1.414 1.414L2 10.414V18a2 2 0 0 0 2 2h3a1 1 0 0 0 1-1v-4a1 1 0 0 1 1-1h2a1 1 0 0 1 1 1v4a1 1 0 0 0 1 1h3a2 2 0 0 0 2-2v-7.586l.293.293a1 1 0 0 0 1.414-1.414Z"/>
      </svg>
    HTML

    SEPARATOR_ICON = <<-HTML
      <svg class="rtl:rotate-180 w-3 h-3 text-gray-400 mx-1" aria-hidden="true" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 6 10">
        <path stroke="currentColor" stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="m1 9 4-4-4-4"/>
      </svg>
    HTML

    DEFAULT_ICON = :separator
    ICON_MAPPINGS = {
      separator: SEPARATOR_ICON,
      home: HOME_ICON,
      none: ""
    }
    ICON_OPTIONS = ICON_MAPPINGS.keys

    def initialize(title, href: nil, icon: DEFAULT_ICON)
      @title = title

      @li_options = {}
      @li_options[:"aria-current"] = "page" if href.nil?

      @href = href

      margin = icon == :home ? "" : "ms-1 md:ms-2"
      @link_options = {
        class: class_names(LINK_CLASS, margin)
      }

      @icon = {}
      @icon[:html] = ICON_MAPPINGS[fetch_or_fallback(ICON_OPTIONS, icon, DEFAULT_ICON)].html_safe
      @icon[:type] = icon.to_sym
    end
  end
end
