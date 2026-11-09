# frozen_string_literal: true

module Gustwave
  # Visuals, i.e. icons, images, SVGs, indicators and custom components, in
  # one of three slots (D7 in docs/design.md):
  # - +leading_visuals+ and +trailing_visuals+, inline with the text on
  #   either side, as in Gustwave::Buttons::Base and Gustwave::Badge.
  # - +visuals+, placed by the component itself, e.g. a toast's icon.
  #
  # Including the concern declares the +visual+ part and the
  # +visual_icon_theme+ setting. Declare the slots the component places with
  # +renders_visuals+:
  #
  #   include Gustwave::Visuals
  #   renders_visuals :leading_visuals, :trailing_visuals
  #
  # Each slot is many and has every type: +icon+, +image+, +svg+,
  # +indicator+ and +renderable+.
  #
  # Sizing is optional. A component with a +size+ variant sizes its visuals
  # through the variant's +visual+ part, and one with an +indicator_size+
  # derived value sizes its indicators per +size+. Without them, the +visual+
  # part's own classes size the visuals, and indicators take
  # Gustwave::Indicator's default size.
  #
  # Leading and trailing visuals sit inline with the text, so declaring
  # either adds the +has_visual+ toggle, which makes the root inline-flex.
  # Call +select_options(has_visual: has_visual?)+ before rendering.
  #
  # Icons default to the outline theme. A component whose Flowbite pattern
  # uses solid icons sets it, so the slot and an +icon:+ shorthand agree:
  #
  #   self.visual_icon_theme = :solid
  #
  # Typically used for icons or decorative visuals going with the label.
  #
  # +aria-hidden="true"+ is automatically applied to hide the image from
  # screen readers, as it is usually decorative and doesn't convey critical
  # information.
  #
  # === Basic usage
  #   render Gustwave::Buttons::Base.new do |button|
  #     button.with_leading_visual_image src: "icon.svg", alt: "Icon description"
  #     "Submit"
  #   end
  #
  # === With custom options
  #   render Gustwave::Buttons::Base.new do |button|
  #     button.with_leading_visual_image src: "icon.svg", alt: "Icon description", class: "w-10 h-10 me-4"
  #     "Submit"
  #   end
  #
  # === Custom visual components
  # Pass any component with +with_leading_visual_renderable+, +with_trailing_visual_renderable+ or +with_visual_renderable+.
  # If it implements +apply_slot_context+, the component calls it when the slot
  # is set, with:
  # - +slot:+ [Symbol] +:leading_visuals+, +:trailing_visuals+ or +:visuals+.
  # - +size:+ [Symbol, nil] the component's size, e.g. +:none+, +:xs+, +:sm+, +:md+, +:lg+ or +:xl+, or +nil+ for a component without one.
  # - +html_attributes:+ [Hash] the attributes the built-in visuals get:
  #   +aria: { hidden: true }+ and the size classes for +size+, e.g.
  #   +h-5 w-auto -mx-0.5+ for +:lg+, or the +visual+ part's classes.
  # The component may add keys later, so accept unknown ones with +**+.
  # Components without +apply_slot_context+ render unchanged.
  #
  #   class MyAvatar < Gustwave::Component
  #     def initialize(src, **options)
  #       @src = src
  #       @options = options
  #     end
  #
  #     def apply_slot_context(html_attributes:, **)
  #       # The caller's own options take precedence over the component's.
  #       @options = configure_html_attributes(@options, **html_attributes)
  #     end
  #
  #     def call
  #       image_tag @src, **@options
  #     end
  #   end
  #
  #   button.with_leading_visual_renderable(MyAvatar.new("me.png", class: "rounded-full"))
  #
  # === Adding a visual type to a component
  # Extend the including component whenever it loads, so the type survives
  # code reloading. Its subclasses inherit it, but components that include
  # Visuals on their own don't:
  #
  #   # config/initializers/gustwave.rb
  #   Rails.autoloaders.main.on_load("Gustwave::Buttons::Base") do |base, _abspath|
  #     base.extend_slot :leading_visuals, types: {
  #       badge: ->(text) { tag.mark(text, **configure_visual_html_attributes({ class: "badge" })) }
  #     }
  #   end
  #
  #   button.with_leading_visual_badge("new")
  #
  # Pass your own attributes to +configure_visual_html_attributes+ as a hash,
  # not as keywords: keywords count as defaults and replace the size classes.
  module Visuals
    extend ActiveSupport::Concern

    # The slots +renders_visuals+ declares.
    SLOTS = %i[leading_visuals trailing_visuals visuals].freeze

    # The slots whose visuals sit inline with the text.
    INLINE_SLOTS = %i[leading_visuals trailing_visuals].freeze

    included do
      # The theme of the +icon+ type, +:outline+ or +:solid+.
      class_attribute :visual_icon_theme,
                      instance_accessor: false,
                      instance_predicate: false,
                      default: :outline

      part :visual
    end

    class_methods do
      # Declares visual slots, each many and with every visual type.
      #
      # @param names [Array<Symbol>] +:leading_visuals+, +:trailing_visuals+ and +:visuals+.
      # @raise [ArgumentError] for any other name.
      def renders_visuals(*names)
        names = names.map(&:to_sym)
        unknown = names - SLOTS
        raise ArgumentError, "Unknown visual slots #{unknown.inspect}, expected some of #{SLOTS.inspect}" if unknown.any?

        if names.intersect?(INLINE_SLOTS) && option_definition.option(:has_visual).nil?
          # Set when a leading or trailing visual is present
          toggle :has_visual, "inline-flex items-center align-bottom gap-1.5", internal: true
        end

        names.each do |name|
          renders_many_extensible name, types: Visuals.slot_types, renderable: :visual_context
        end
      end
    end

    # @return [Hash{Symbol => Proc}] the types of a visual slot, a new hash
    #   for each slot.
    def self.slot_types
      {
        icon: ->(name, theme: nil, **options) {
          config = configure_visual_html_attributes(options, theme: theme || self.class.visual_icon_theme)
          Gustwave::Icon.new(name, **config)
        },
        image: ->(src, **options) {
          config = configure_visual_html_attributes(options)
          image_tag src, **config
        },
        svg: ->(src = nil, **options, &block) {
          config = configure_visual_html_attributes(options)
          Gustwave::Svg.new(src, **config, &block)
        },
        indicator: ->(text = nil, **options, &block) {
          size = derived_value(:indicator_size) if self.class.option_definition.derived(:indicator_size)
          config = configure_html_attributes(options, aria: { hidden: true }, **{ size: }.compact)
          Gustwave::Indicator.new(text, **config, &block)
        }
      }
    end

    private

    # Whether a leading or trailing visual is present.
    def has_visual?
      INLINE_SLOTS.any? { |slot| respond_to?(:"#{slot}?") && public_send(:"#{slot}?") }
    end

    # Context for components passed to the +renderable+ visual type that
    # implement +apply_slot_context+. Documented in the module comment under
    # "Custom visual components"; keep both in sync.
    def visual_context
      size = option_value(:size) if self.class.option_definition.enum_option(:size)
      { size:, html_attributes: configure_visual_html_attributes }
    end

    def configure_visual_html_attributes(overwrite_attrs = {}, **default_attrs)
      configure_html_attributes(
        overwrite_attrs,
        aria: { hidden: true },
        class: classes(:visual),
        **default_attrs
      )
    end
  end
end
