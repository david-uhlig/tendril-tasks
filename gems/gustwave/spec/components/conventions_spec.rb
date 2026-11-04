require "rails_helper"

# Checks the conventions of docs/design.md that can be read off a component's
# declarations and source. Each rule reports findings like
# "icon_keyword: icon" per component.
#
# - known_violations: components written before the design doc, each finding
#   with the gustwave-design issue that fixes it. The list only shrinks: a
#   finding that's gone fails until it's removed here.
# - exceptions: findings that are fine for good, each with its reason.
RSpec.describe "Component conventions" do
  design = "docs/design.md"
  code = ->(component) {
    file, = Object.const_source_location(component.name)
    File.readlines(file).grep_v(/\A\s*#/).join
  }
  keywords = ->(component) {
    component.instance_method(:initialize).parameters.select { |type, _| %i[key keyreq].include?(type) }.to_h { |type, name| [ name, type ] }
  }
  slots = ->(component) { component.registered_slots.keys }

  rules = {
    part_options: {
      section: "styling-a-part",
      rule: "A <name>_options: keyword names a declared part, or a component the component renders for it",
      check: ->(component) {
        parts = component.style_definition.parts
        keywords.(component).keys.grep(/_options\z/).reject { |name| parts.include?(name.to_s.delete_suffix("_options").to_sym) }
      }
    },
    class_keyword: {
      section: "styling-a-part",
      rule: "Style an element with <part>_options:, not <part>_class:; <state>_class: is only for classes a script swaps",
      check: ->(component) { keywords.(component).keys.grep(/_class\z/) }
    },
    configure_method: {
      section: "styling-a-part",
      rule: "Style a part with <part>_options:, not a public configure_<part> method",
      check: ->(component) { (component.public_instance_methods - Gustwave::Component.public_instance_methods).grep(/\Aconfigure_/) }
    },
    icon_keyword: {
      section: "icons-and-other-visuals",
      rule: "icon: and trailing_icon: are shorthand for a slot callers can also set, never the only way",
      check: ->(component) {
        found = keywords.(component).keys & %i[icon trailing_icon]
        reachable = (slots.(component) & %i[leading_visuals trailing_visuals icon]).any? || code.(component).include?("delegate_missing_to")
        reachable ? [] : found
      }
    },
    dismiss_slot: {
      section: "dismiss-and-close-buttons",
      rule: "A component that renders Gustwave::DismissButton exposes it as a dismiss_button slot",
      check: ->(component) {
        renders = code.(component).match?(/\bDismissButton\.new\b/)
        renders && !slots.(component).include?(:dismiss_button) ? [ "no dismiss_button slot" ] : []
      }
    },
    button_keyword: {
      section: "dismiss-and-close-buttons",
      rule: "Dismiss and close buttons are slots; a dismiss_button: or close_button: keyword needs the slot as well",
      check: ->(component) { (keywords.(component).keys & %i[dismiss_button close_button]).reject { |name| slots.(component).include?(name) } }
    },
    trigger_name: {
      section: "triggers",
      rule: "Flowbite's hover or click trigger setting is called trigger_event, because trigger is a slot name",
      check: ->(component) {
        found = []
        found << "option trigger" if component.option_definition.options.key?(:trigger)
        found << "trigger:" if keywords.(component).key?(:trigger)
        takes_trigger = ->(method) { method.parameters.any? { |_, name| name == :trigger } }
        found << "trigger_options(trigger:)" if component.method_defined?(:trigger_options) && takes_trigger.(component.instance_method(:trigger_options))
        found << "self.trigger_options(trigger:)" if component.respond_to?(:trigger_options) && takes_trigger.(component.method(:trigger_options))
        found
      }
    },
    parent_id: {
      section: "wiring-and-accessibility",
      rule: "A standalone sub-component requires its parent's ID as <parent>_id:",
      check: ->(component) {
        own = component.name.demodulize.underscore
        keywords.(component).filter_map { |name, type| name if name.end_with?("_id") && name != :id && own.start_with?(name.to_s.delete_suffix("_id")) && type != :keyreq }
      }
    }
  }

  known_violations = {
    "Gustwave::DismissButton" => { "icon_keyword: icon" => 520 },
    "Gustwave::DrawerHeader" => { "icon_keyword: icon" => 520 },
    "Gustwave::IconToast" => { "icon_keyword: icon" => 519 },
    "Gustwave::Pagination::Link" => { "icon_keyword: icon" => 520 },
    "Gustwave::SpeedDials::Action" => { "icon_keyword: icon" => 520 },
    "Gustwave::SpeedDials::Trigger" => { "icon_keyword: icon" => 520 }
  }

  exceptions = {
    "Gustwave::DismissButton" => {
      "part_options: icon_options" => "Options for the Gustwave::Icon it renders as its icon."
    },
    "Gustwave::Dropdown" => {
      "icon_keyword: icon" => "Shorthand for the default trigger; the trigger slot's generic and component types render any visual.",
      "icon_keyword: trailing_icon" => "Shorthand for the default trigger; the trigger slot's generic and component types render any visual."
    },
    "Gustwave::ModalHeader" => {
      "part_options: title_options" => "Options for the Gustwave::Heading it renders as its title."
    },
    "Gustwave::Tabs" => {
      "class_keyword: active_class" => "State classes Flowbite's JavaScript swaps on the selected tab (D5).",
      "class_keyword: inactive_class" => "State classes Flowbite's JavaScript swaps on the unselected tabs (D5)."
    }
  }

  components = Gustwave::ComponentStatus.components

  components.each do |component|
    it "#{component.name} follows the conventions" do
      found = rules.flat_map { |key, rule| rule[:check].(component).map { |detail| "#{key}: #{detail}" } }
      known = known_violations.fetch(component.name, {})
      excepted = exceptions.fetch(component.name, {})

      new_findings = (found - known.keys - excepted.keys).map do |finding|
        rule = rules.fetch(finding.split(":").first.to_sym)
        "#{finding}. #{rule[:rule]}. See #{design}##{rule[:section]}"
      end
      expect(new_findings).to be_empty, "#{component.name}:\n  #{new_findings.join("\n  ")}"

      fixed = (known.keys - found).map { |finding| "#{finding} (##{known[finding]})" }
      expect(fixed).to be_empty,
        "#{component.name} now follows the conventions for #{fixed.join(", ")}. Remove them from known_violations."

      unused = excepted.keys - found
      expect(unused).to be_empty, "#{component.name} no longer needs the exceptions #{unused.join(", ")}. Remove them."
    end
  end

  it "lists only existing components" do
    names = components.map(&:name)

    expect(known_violations.keys + exceptions.keys - names).to be_empty
  end
end
