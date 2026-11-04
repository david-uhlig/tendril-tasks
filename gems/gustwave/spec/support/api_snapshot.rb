# frozen_string_literal: true

require_relative "../../lookbook/component_status"

# A plain description of a component's public and extension API, see "Public
# API and stability" in docs/design.md. spec/components/api_snapshot_spec.rb
# compares it to a committed fixture, so every API change shows up in review.
#
# Internal options (+internal: true+) and ViewComponent's own methods are left
# out: changing them isn't breaking.
module ApiSnapshot
  # Public methods ViewComponent defines for every component
  VIEW_COMPONENT_METHODS = /\A(call|_call_.*|before_render|render\?)\z/

  module_function

  # @param component [Class] a Gustwave component
  # @return [Hash] the snapshot, with string keys and values so it reads well as YAML
  def for(component)
    {
      "status" => Gustwave::ComponentStatus.for(component),
      "constructor" => constructor(component),
      "options" => options(component),
      "derived" => derived(component),
      "parts" => component.style_definition.parts.excluding(:root).map(&:to_s).sort,
      "slots" => slots(component),
      "methods" => names(component.public_instance_methods - Gustwave::Component.public_instance_methods)
                     .grep_v(VIEW_COMPONENT_METHODS),
      "class_methods" => names(component.singleton_class.public_instance_methods -
                               Gustwave::Component.singleton_class.public_instance_methods),
      "slot_builders" => names(component.private_instance_methods.grep(/\Abuild_slot_/))
    }.reject { |_, value| value.blank? }
  end

  # Positional and keyword parameters, e.g. "text (optional)", "modal_id:" or
  # "tag: (optional)".
  def constructor(component)
    component.instance_method(:initialize).parameters.map do |type, name|
      case type
      when :req then name.to_s
      when :opt then "#{name} (optional)"
      when :rest then "*#{name}"
      when :keyreq then "#{name}:"
      when :key then "#{name}: (optional)"
      when :keyrest then "**#{name}"
      when :block then "&#{name}"
      end
    end
  end

  def options(component)
    component.option_definition.options.values.reject(&:internal?).sort_by(&:name).to_h do |option|
      described = { "default" => option.default.to_s }
      described["values"] = option.values.map(&:to_s) unless option.boolean?
      [ option.name.to_s, described ]
    end
  end

  def derived(component)
    component.option_definition.derived_values.values.sort_by(&:name).to_h do |derived|
      [ derived.name.to_s, { "from" => derived.from.to_s } ]
    end
  end

  def slots(component)
    component.registered_slots.keys.sort.to_h do |name|
      slot = component.registered_slots[name]
      extensible = component.extensible_slots[name]
      described = { "many" => slot[:collection] == true }
      described["types"] = extensible[:types].map(&:to_s).sort if extensible&.key?(:types)
      described["extensible"] = false unless extensible
      [ name.to_s, described ]
    end
  end

  def names(methods)
    methods.map(&:to_s).sort
  end
end
