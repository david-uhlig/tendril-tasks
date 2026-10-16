# frozen_string_literal: true

module Gustwave
  # Base class of Gustwave's components.
  #
  # === Constructor convention
  #
  #   def initialize(text = nil, tag: DEFAULT, scheme: DEFAULT, pill: false, **options)
  #     @text = text
  #     select_options(tag:, scheme:, pill:)
  #     @tag = option_value(:tag)
  #     @options = attributes_for(options)
  #   end
  #
  # * Positional arguments are the component's content or subject, e.g. its
  #   +text+ or an icon's +name+.
  # * A keyword argument that picks from a fixed list, e.g. +tag+, +scheme+ or
  #   +size+, is one of the component's options, declared with +option+,
  #   +variant+ or +toggle+ under the same name (see Gustwave::Options and
  #   Gustwave::Styling). It defaults to +DEFAULT+, or to +false+ for a toggle
  #   that is off by default, goes through +select_options+ and is read back
  #   with +option_value+. When its default depends on another option, the
  #   component takes it from a +derive+d value instead, e.g. the scheme per
  #   tag in Gustwave::Heading.
  # * A keyword argument forwarded to a child component defaults to +DEFAULT+,
  #   so the child's default applies, unless the component deliberately picks
  #   another one for its child. Prefer forwarding through +options+.
  # * +options+ holds HTML attributes, or the arguments of the component a
  #   component wraps.
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

    # Returns configured HTML attributes and component settings for the
    # component or slot.
    #
    # Merges +overwrite_attrs+ into +default_attrs+ so that +overwrite_attrs+
    # takes precedence. With special handling for the +class+ attribute to apply
    # semantic CSS merging with TailwindMerge.
    #
    # @param overwrite_attrs [Hash] HTML attributes and component arguments to be added or overridden if present in +default_attrs+.
    # @param overwrite_class_attr [Boolean] How to handle the +class+ attribute. When set to +false+, the CSS classes of +overwrite_attrs+ and +default_attrs+ are fused semantically with TailwindMerge. CSS classes in +overwrite_attrs+ take precedence. When set to +true+, the default Ruby merging strategy applies, replacing +default_attrs+ CSS classes with +overwrite_attrs+ CSS classes.
    # @param default_attrs [Hash] Default HTML attribute and component configuration for the component or slot.
    # @return [Hash] The configured HTML default_attrs.
    def configure_html_attributes(overwrite_attrs = {}, overwrite_class_attr: false, **default_attrs)
      return default_attrs if overwrite_attrs.blank?

      overwrite_attrs = overwrite_attrs.deep_symbolize_keys
      unless overwrite_class_attr
        # A caller's class: nil adds no classes, like class: "", instead of
        # replacing the defaults.
        overwrite_attrs.delete(:class) if overwrite_attrs[:class].nil?
        if overwrite_attrs.key?(:class)
          overwrite_attrs[:class] = merge_classes(default_attrs[:class], overwrite_attrs[:class])
        end
      end

      default_attrs.merge(overwrite_attrs)
    end
  end
end
