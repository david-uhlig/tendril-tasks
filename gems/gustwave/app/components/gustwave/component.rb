# frozen_string_literal: true

module Gustwave
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
