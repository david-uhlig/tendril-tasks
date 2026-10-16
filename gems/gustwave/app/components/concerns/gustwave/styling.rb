# frozen_string_literal: true

module Gustwave
  # Declares a component's CSS classes and computes them for the options a
  # caller picked. Builds on Gustwave::Options, which holds the options and
  # their values.
  #
  # === Declaring styles
  #
  #   class Badge < Gustwave::Component
  #     base     "inline-flex items-center rounded-sm"
  #     unstyled scheme: :none
  #     part     :icon, "h-3 w-auto"
  #
  #     variant :scheme, default: :gray, values: {
  #       gray: "bg-gray-100 text-gray-800",
  #       red:  "bg-red-100 text-red-800"
  #     }
  #     variant :size, default: :md, values: {
  #       sm: { root: "text-xs px-1.5", icon: "h-2.5" },
  #       md: "text-sm px-2"
  #     }
  #     toggle  :pill, "rounded-full"
  #     toggle  :border, per: :scheme, values: { gray: "ring-1 ring-gray-300", red: "ring-1 ring-red-300" }
  #   end
  #
  # * +base+ styles the root element, or several parts when given a hash.
  # * +unstyled+ names the option values that render the component
  #   unstyled, i.e. without its base styles, so callers can bring their
  #   own. By convention that's <tt>scheme: :none</tt>. Subclasses inherit it.
  # * +part+ declares a named element besides the root, e.g. an icon slot,
  #   optionally with its own classes.
  # * +variant+ declares an option with a fixed set of values and a
  #   +default:+, and the classes of each value. A variant without a +:none+
  #   value gets one that adds no classes.
  # * +toggle+ declares an on/off option, off unless given +default: true+,
  #   and its classes. It can style both states (+on:+ / +off:+) or depend on
  #   another option (+per:+).
  #
  # Variants and toggles take +internal: true+ for state the component
  # selects itself, as options do; see Gustwave::Options.
  #
  # Read the option of a variant or toggle with +option_value+, and derive
  # values from it with +derive+, as for any option; see Gustwave::Options.
  #
  # A plain string targets the root element, or the part named by +part:+. A
  # hash targets parts by name: <tt>{ root: "…", icon: "…" }</tt>. Every
  # declaration takes +unless:+ to skip it for some option values, e.g.
  # <tt>unless: { scheme: :none }</tt> or <tt>unless: { size: [:xs, :sm] }</tt>.
  #
  # Classes are emitted in declaration order, inherited declarations first,
  # and merged with TailwindMerge, so a later declaration wins a conflict.
  #
  # === Inheritance and extension
  #
  # Subclasses inherit every declaration. Declaring a name again replaces it
  # in place; nothing merges implicitly. To change an inherited variant or
  # toggle partially, use +extend_variant+ or +extend_toggle+, which merge per
  # value and per part. Change the base or a part by declaring it again.
  # +remove_part+, +remove_variant+ and +remove_toggle+ delete one.
  #
  # Definitions are resolved on first use and again after any declaration, so
  # extending a parent class, e.g. from a Zeitwerk +on_load+ hook, reaches
  # subclasses that are already loaded:
  #
  #   Rails.autoloaders.main.on_load("Gustwave::Buttons::Base") do |base, _abspath|
  #     base.extend_variant :scheme, values: { brand: "bg-brand-600 text-white" }
  #   end
  #
  # A subclass that redefines the variant instead of extending it doesn't see
  # the extension. Mistakes such as an unknown part, a missing default or a
  # +per:+ toggle that doesn't cover every value raise a
  # Gustwave::DefinitionError when the definition is resolved, in every
  # environment.
  #
  # So does a +per:+ toggle or derived value in a subclass that the extension
  # leaves without a value. Gustwave::Badge styles its border, outline and
  # hover per scheme, and derives its dismiss button's scheme from it, so
  # extend those in the same hook:
  #
  #   Rails.autoloaders.main.on_load("Gustwave::Badge") do |badge, _abspath|
  #     badge.extend_variant :scheme, values: { brand: "bg-brand-600 text-white" }
  #     badge.extend_toggle :border, values: { brand: "border border-brand-400" }
  #     badge.extend_toggle :outline, values: { brand: "outline outline-1 outline-brand-400" }
  #     badge.extend_toggle :hover, values: { brand: "hover:bg-brand-700" }
  #     badge.extend_derived :dismiss_button_scheme, values: { brand: :base }
  #   end
  #
  # === Using styles in a component
  #
  # Select the options as described in Gustwave::Options, then add the
  # computed classes to the HTML attributes:
  #
  #   def initialize(text = nil, scheme: DEFAULT, size: DEFAULT, pill: false, **options)
  #     select_options(scheme:, size:, pill:)
  #     @options = attributes_for(options)
  #   end
  #
  # +attributes_for+ adds the computed classes to +options+, merged with the
  # caller's +class+.
  module Styling
    extend ActiveSupport::Concern
    include Gustwave::Options

    # Raised when Gustwave.strict? for a part the component doesn't declare.
    class UnknownPartError < Gustwave::Error
      def initialize(component, given:, expected:)
        super(Options.suggest("#{component} has no part #{given.inspect}", given, expected))
      end
    end

    class_methods do
      # Styles the root element, or several parts given as a hash.
      #
      #   base "inline-flex items-center", unless: { scheme: :none }
      #   base root: "relative", icon: "absolute"
      def base(classes = nil, **parts)
        options = parts.extract!(:unless)
        declare_styling(:base, classes: style_targets(classes || parts), unless: style_unless(options))
      end

      # Skips the base styles for the given option values, rendering the
      # component unstyled. Replaces an inherited declaration.
      #
      #   unstyled scheme: :none
      def unstyled(**conditions)
        declare_styling(:unstyled, unless: style_unless({ unless: conditions }))
      end

      # Declares a part, an element besides the root, with optional classes.
      def part(name, classes = nil, **options)
        declare_styling(:part, name: name.to_sym, classes: classes, unless: style_unless(options))
      end

      # Declares a variant: an option with fixed values and a default, and the
      # classes of each value.
      #
      #   variant :size, default: :md, values: { sm: "text-sm", md: "text-base" }
      #   variant :size, part: :icon, default: :md, values: { sm: "h-4", md: "h-5" }
      #
      # +internal: true+ marks a variant the component selects itself.
      def variant(name, default:, values:, part: Definition::ROOT, internal: false, **options)
        values = style_values(values, part)
        declare_option(:option, name:, kind: :variant, default: Options.normalize_value(default),
                                values: values.keys, implicit_none: true, internal: internal == true)
        declare_styling(:variant, name: name.to_sym, values:, unless: style_unless(options))
      end

      # Declares a toggle: an on/off option, off unless given +default: true+,
      # and its classes.
      #
      #   toggle :pill, "rounded-full"
      #   toggle :visible, default: true, on: "opacity-100", off: "opacity-0"
      #   toggle :border, per: :size, values: { sm: "ring-1", md: "ring-2" }
      #
      # +internal: true+ marks a toggle the component selects itself, e.g.
      # whether it renders any text.
      def toggle(name, classes = nil, on: nil, off: nil, per: nil, values: {}, part: Definition::ROOT, default: false,
                 internal: false, **options)
        declare_option(:option, name:, kind: :toggle, default: default == true, values: [ false, true ],
                                internal: internal == true)
        declare_styling(:toggle, name: name.to_sym,
                                 on: style_targets(classes || on, part), off: style_targets(off, part),
                                 per: per&.to_sym, values: style_values(values, part), unless: style_unless(options))
      end

      # Merges values into an inherited variant, per value and part, and
      # optionally changes its default.
      def extend_variant(name, default: nil, values: {}, part: Definition::ROOT, **options)
        values = style_values(values, part)
        declare_option(:extend_option, name:, kind: :variant, default: default && Options.normalize_value(default),
                                       values: values.keys)
        declare_styling(:extend_variant, name: name.to_sym, values:, unless: style_unless(options, keep: true))
      end

      # Merges classes into an inherited toggle, per state, value and part.
      def extend_toggle(name, classes = nil, on: nil, off: nil, values: {}, part: Definition::ROOT, **options)
        declare_styling(:extend_toggle, name: name.to_sym,
                                        on: style_targets(classes || on, part), off: style_targets(off, part),
                                        values: style_values(values, part), unless: style_unless(options, keep: true))
      end

      def remove_part(name)
        declare_styling(:remove_part, name: name.to_sym)
      end

      # Removes the variant's option, and with it its classes.
      def remove_variant(name)
        declare_option(:remove_option, name:, kind: :variant)
      end

      # Removes the toggle's option, and with it its classes.
      def remove_toggle(name)
        declare_option(:remove_option, name:, kind: :toggle)
      end

      # Sets or returns the TailwindMerge instance that merges this
      # component's classes. Inherited by subclasses.
      def class_merger(merger = nil)
        return @class_merger = merger if merger

        @class_merger || (superclass.respond_to?(:class_merger) ? superclass.class_merger : TailwindHelper::MERGER)
      end

      # The resolved styling of this class, including inherited declarations.
      #
      # @return [Gustwave::Styling::Definition]
      # @raise [Gustwave::DefinitionError] if the declarations of styles or
      #   options are inconsistent.
      def style_definition
        options = option_definition
        if @style_definition.nil? || @style_definition_version != Options.version
          parent = superclass.style_definition if superclass.respond_to?(:style_definition)
          @style_definition = Definition.build(name || inspect, parent, @styling_declarations || [], options)
          @style_definition_version = Options.version
        end
        @style_definition
      end

      private

      def declare_styling(action, **args)
        (@styling_declarations ||= []) << [ action, args ]
        Options.changed!
        nil
      end

      # "classes" → { target => "classes" }, { root: …, icon: … } stays.
      def style_targets(classes, target = Definition::ROOT)
        case classes
        when nil then {}
        when Hash then classes.to_h { |part, value| [ part.to_sym, value.to_s ] }
        else { target.to_sym => classes.to_s }
        end
      end

      def style_values(values, target)
        values.to_h { |value, classes| [ Options.normalize_value(value), style_targets(classes, target) ] }
      end

      def style_unless(options, keep: false)
        options.assert_valid_keys(:unless)
        return nil if keep && !options.key?(:unless)

        (options[:unless] || {}).to_h do |name, values|
          [ name.to_sym, Array(values).map { |value| value == true || value == false ? value : Options.normalize_value(value) } ]
        end
      end
    end

    # Returns the classes of the root element or a part, or +nil+ if there are
    # none. Options given here override the selection for this call, and
    # +class:+ adds classes (a string or an array) that win conflicts.
    #
    #   classes                       # root element
    #   classes(:icon)                # a part
    #   classes(pill: true, class: "ms-2")
    def classes(part = Definition::ROOT, **overrides)
      extra = overrides.delete(:class)
      definition = self.class.style_definition
      part = part.to_sym

      unless definition.part?(part)
        raise UnknownPartError.new(option_component_name, given: part, expected: definition.parts) if Gustwave.strict?

        return merge_classes(extra)
      end

      merge_classes(definition.classes_for(part, option_values_for(overrides)), extra)
    end

    # Returns the HTML attributes +options+ with the classes of the root
    # element or a part, merged with +options[:class]+.
    #
    #   attributes_for(options)
    #   attributes_for(:icon, options, pill: true)
    def attributes_for(*args, **overrides)
      part = args.first.is_a?(Symbol) || args.first.is_a?(String) ? args.shift : Definition::ROOT
      attributes = (args.first || {}).to_h.symbolize_keys
      merged = classes(part, **overrides, class: attributes[:class])
      merged ? attributes.merge(class: merged) : attributes.except(:class)
    end

    # Merges class strings or arrays with the component's class merger.
    #
    # @return [String, nil]
    def merge_classes(*classes)
      self.class.class_merger.merge(classes.flatten.compact_blank).presence
    end
  end
end
