# frozen_string_literal: true

module Gustwave
  # Reads a component's status from the +@status+ tag in its class docstring,
  # see "Component lifecycle" in docs/design.md. Used by the specs and by
  # Lookbook's status panel, see config/initializers/lookbook.rb in the host
  # application. Never shipped with the gem.
  module ComponentStatus
    # What each status promises callers, as in the README's "Component status"
    MEANINGS = {
      "alpha" => "May change in any minor release. Every change comes with an upgrade note.",
      "beta" => "The API has settled. Anything removed is deprecated one minor release first.",
      "stable" => "Like beta while Gustwave is at 0.x. From 1.0, removals only come in a major release.",
      "deprecated" => "Logs a warning and is removed in the next minor release."
    }.freeze
    STATUSES = MEANINGS.keys.freeze
    TAG = /\A\s*#\s*@status\b\s*(.*?)\s*\z/
    COMMENT = /\A\s*#/

    module_function

    # Every component class defined in the gem's app/components, sorted by name.
    #
    # @return [Array<Class>]
    def components
      Rails.autoloaders.main.eager_load_dir(components_root)
      Gustwave::Component.descendants.select { |component| defined_in_gem?(component) }.sort_by(&:name)
    end

    # The values of every +@status+ tag in the component's class docstring,
    # valid or not.
    #
    # @param component [Class] a Gustwave component
    # @return [Array<String>]
    def tags(component)
      docstring(component).filter_map { |line| line[TAG, 1] }
    end

    # The component's status.
    #
    # @param component [Class] a Gustwave component
    # @return [String, nil] the status, or +nil+ unless the docstring has exactly
    #   one valid +@status+ tag
    def for(component)
      found = tags(component)
      found.first if found.one? && STATUSES.include?(found.first)
    end

    # The component a preview shows, by name: +Gustwave::CardPreview+ shows
    # +Gustwave::Card+.
    #
    # @param preview_class [Class] a ViewComponent preview class
    # @return [Class, nil] the component, or +nil+ if there's none by that name
    def component_for_preview(preview_class)
      component = preview_class.name.to_s.delete_suffix("Preview").safe_constantize
      component if component.is_a?(Class) && component < Gustwave::Component
    end

    # The comment lines directly above the component's class definition.
    def docstring(component)
      return [] unless component&.name

      file, line = Object.const_source_location(component.name)
      return [] unless file

      File.readlines(file, chomp: true).first(line - 1).reverse.take_while { |l| l.match?(COMMENT) }.reverse
    end

    def defined_in_gem?(component)
      return false unless component.name

      file, = Object.const_source_location(component.name)
      file.to_s.start_with?("#{components_root}/")
    end

    def components_root
      Gustwave::Engine.root.join("app/components").to_s
    end
  end
end
