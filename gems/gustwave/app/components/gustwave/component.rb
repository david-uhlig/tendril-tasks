# frozen_string_literal: true

module Gustwave
  # Base class of Gustwave's components.
  #
  # === Constructor convention
  #
  #   def initialize(text = nil, tag: DEFAULT, color: DEFAULT, pill: false, **options)
  #     @text = text
  #     select_options(tag:, color:, pill:)
  #     @tag = option_value(:tag)
  #     @options = attributes_for(options)
  #   end
  #
  # * Positional arguments are the component's content or subject, e.g. its
  #   +text+ or an icon's +name+.
  # * A keyword argument that picks from a fixed list, e.g. +tag+, +color+ or
  #   +size+, is one of the component's options, declared with +option+,
  #   +variant+ or +toggle+ under the same name (see Gustwave::Options and
  #   Gustwave::Styling). It defaults to +DEFAULT+, or to +false+ for a toggle
  #   that is off by default, goes through +select_options+ and is read back
  #   with +option_value+. When its default depends on another option, the
  #   component takes it from a +derive+d value instead, e.g. the color per
  #   tag in Gustwave::Heading.
  # * Callers can pick every option through a keyword argument, except one
  #   marked +internal: true+, which the component selects itself, e.g. from
  #   its content in +before_render+.
  # * A keyword argument forwarded to a child component defaults to +DEFAULT+,
  #   so the child's default applies, unless the component deliberately picks
  #   another one for its child. Prefer forwarding through +options+.
  # * +options+ holds HTML attributes, or the arguments of the component a
  #   component wraps.
  # * +html:+ is taken by +new+, not by +initialize+, so no component
  #   declares it. It holds HTML attributes for the element +options+ go to
  #   and is the only way to pass an attribute named like one of the
  #   component's options: <tt>size: :lg, html: { size: 5 }</tt>. See
  #   Gustwave::Component.new.
  #
  # The gem's specs check every component against this convention.
  class Component < ViewComponent::Base
    include Gustwave::ContentHelper
    include Gustwave::HtmlAttributesHelper
    include Gustwave::Options
    include Gustwave::Styling
    include Gustwave::ExtensibleSlots
    include Gustwave::FetchOrFallbackHelper
    include Gustwave::TailwindHelper

    class << self
      # Builds the component. Next to the arguments of +initialize+ it takes
      # +html:+, a hash of HTML attributes for the element the component's
      # +options+ go to.
      #
      #   Gustwave::Tabs.new(style: :underline, html: { style: "max-width: 40rem" })
      #
      # A keyword named like one of the component's options is always the
      # option, so +html:+ is the only way to pass the HTML attribute of that
      # name. Every other attribute works flat as well, e.g. +placeholder:+
      # or +class:+. An attribute given both flat and in +html:+ takes the
      # value in +html:+. That holds for +class+, +data+ and +aria+ too, which
      # then merge with the component's own as the flat ones do.
      #
      # An attribute named like an option reaches +initialize+ in +options+
      # under a String key, e.g. <tt>"size"</tt>, so no keyword argument takes
      # it. Every other attribute is merged into +options+ under its Symbol
      # key.
      #
      # @param html [Hash, nil] HTML attributes for the element the component's +options+ go to.
      # @raise [ArgumentError] if +html+ is neither a Hash nor +nil+.
      def new(*args, html: nil, **options, &block)
        return super(*args, **options, &block) if html.nil?
        raise ArgumentError, "html: takes a Hash of HTML attributes, got #{html.inspect}" unless html.is_a?(Hash)

        merged = html.each_with_object(options.dup) do |(name, value), result|
          name = name.to_sym
          if option_definition.option(name)
            result[name.to_s] = value
          else
            result[name] = value
          end
        end
        super(*args, **merged, &block)
      end
    end

    # Returns configured HTML attributes and component settings for the
    # component or slot.
    #
    # Merges +overwrite_attrs+ into +default_attrs+ so that +overwrite_attrs+
    # takes precedence. With special handling for the +class+ attribute to apply
    # semantic CSS merging with TailwindMerge.
    #
    # The +data+ and +aria+ hashes are merged one level deeper, so a caller's
    # <tt>data: { controller: "x" }</tt> adds to the default +data+ instead of
    # replacing it. Keys within them follow the same precedence, e.g.
    # <tt>aria: { hidden: false }</tt> overrides a default
    # <tt>aria: { hidden: true }</tt>.
    #
    # An +html+ hash within +overwrite_attrs+ is merged into it first, and
    # its attributes replace the ones of the same name next to it (see
    # Gustwave::Component.new).
    #
    # @param overwrite_attrs [Hash] HTML attributes and component arguments to be added or overridden if present in +default_attrs+.
    # @param overwrite_class_attr [Boolean] How to handle the +class+ attribute. When set to +false+, the CSS classes of +overwrite_attrs+ and +default_attrs+ are fused semantically with TailwindMerge. CSS classes in +overwrite_attrs+ take precedence. When set to +true+, the default Ruby merging strategy applies, replacing +default_attrs+ CSS classes with +overwrite_attrs+ CSS classes.
    # @param default_attrs [Hash] Default HTML attribute and component configuration for the component or slot.
    # @return [Hash] The configured HTML default_attrs.
    def configure_html_attributes(overwrite_attrs = {}, overwrite_class_attr: false, **default_attrs)
      return default_attrs if overwrite_attrs.blank?

      overwrite_attrs = Gustwave::HtmlAttributesHelper.merge_html(overwrite_attrs.deep_symbolize_keys)
      unless overwrite_class_attr
        # A caller's class: nil adds no classes, like class: "", instead of
        # replacing the defaults.
        overwrite_attrs.delete(:class) if overwrite_attrs[:class].nil?
        if overwrite_attrs.key?(:class)
          overwrite_attrs[:class] = merge_classes(default_attrs[:class], overwrite_attrs[:class])
        end
      end

      %i[data aria].each do |key|
        next unless default_attrs[key].is_a?(Hash) && overwrite_attrs[key].is_a?(Hash)

        overwrite_attrs[key] = default_attrs[key].deep_symbolize_keys.merge(overwrite_attrs[key])
      end

      default_attrs.merge(overwrite_attrs)
    end
  end
end
