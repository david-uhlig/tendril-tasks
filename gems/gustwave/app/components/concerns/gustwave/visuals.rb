# frozen_string_literal: true

module Gustwave
  # Leading and trailing visuals, i.e. icons, images, SVGs and indicators
  # beside a component's text, as in Gustwave::Buttons::Base and
  # Gustwave::Badge.
  #
  # Including the concern declares the +leading_visuals+ and
  # +trailing_visuals+ slots, the +has_visual+ toggle and the +visual+ part.
  # The including component must declare:
  # - a +size+ variant, whose +visual+ part sizes the visuals to match the
  #   text.
  # - an +indicator_size+ derived value, the size of leading and trailing
  #   indicators per +size+. Extend it along with +size+, e.g. with +:auto+
  #   to scale with the text.
  #
  # Call +style_with(has_visual: has_visual?)+ before rendering.
  #
  # Renders visual elements to appear to the left or the right of the text.
  #
  # Typically used for icons or decorative visuals going with the label.
  #
  # +aria-hidden="true"+ is automatically applied to hide the image from
  # screen readers, as it is usually decorative and doesn't convey critical
  # information.
  #
  # === Basic usage
  #   render Gustwave::Buttons::Base.new do |button|
  #     button.leading_image src: "icon.svg", alt: "Icon description"
  #     "Submit"
  #   end
  #
  # === With custom options
  #   render Gustwave::Buttons::Base.new do |button|
  #     button.leading_image src: "icon.svg", alt: "Icon description", class: "w-10 h-10 me-4"
  #     "Submit"
  #   end
  #
  # === Custom visual components
  # Pass any component with +leading_renderable+ or +trailing_renderable+.
  # If it implements +apply_slot_context+, the component calls it when the slot
  # is set, with:
  # - +slot:+ [Symbol] +:leading_visuals+ or +:trailing_visuals+.
  # - +size:+ [Symbol] the component's size, e.g. +:none+, +:xs+, +:sm+, +:md+, +:lg+ or +:xl+.
  # - +html_attributes:+ [Hash] the attributes the built-in visuals get:
  #   +aria: { hidden: true }+ and the size classes for +size+, e.g.
  #   +h-6 w-auto+ for +:lg+.
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
  #   button.leading_renderable(MyAvatar.new("me.png", class: "rounded-full"))
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

    included do
      # Set when a leading or trailing visual is present
      toggle :has_visual, "inline-flex items-center align-bottom gap-1.5"

      part :visual

      renders_many_extensible :leading_visuals, types: {
        icon: ->(name, theme: :outline, **options) {
          config = configure_visual_html_attributes(
            options,
            theme:,
            position: :standalone,
          )
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
          config = configure_html_attributes(
            options,
            aria: { hidden: true },
            size: derived_value(:indicator_size),
            )
          Gustwave::Indicator.new(text, **config, &block)
        }
      }, renderable: :visual_context
      alias leading_icon with_leading_visual_icon
      alias leading_image with_leading_visual_image
      alias leading_svg with_leading_visual_svg
      alias leading_indicator with_leading_visual_indicator
      alias leading_renderable with_leading_visual_renderable

      renders_many_extensible :trailing_visuals, types: {
        icon: ->(name, theme: :outline, **options) {
          config = configure_visual_html_attributes(
            options,
            theme:,
            position: :standalone
          )
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
          config = configure_html_attributes(
            options,
            aria: { hidden: true },
            size: derived_value(:indicator_size),
          )
          Gustwave::Indicator.new(text, **config, &block)
        }
      }, renderable: :visual_context
      alias trailing_icon with_trailing_visual_icon
      alias trailing_image with_trailing_visual_image
      alias trailing_svg with_trailing_visual_svg
      alias trailing_indicator with_trailing_visual_indicator
      alias trailing_renderable with_trailing_visual_renderable
    end

    private

    def has_visual?
      @has_visual ||= leading_visuals? || trailing_visuals?
    end

    # Context for components passed to the +renderable+ visual type that
    # implement +apply_slot_context+. Documented in the module comment under
    # "Custom visual components"; keep both in sync.
    def visual_context
      { size: style_value(:size), html_attributes: configure_visual_html_attributes }
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
