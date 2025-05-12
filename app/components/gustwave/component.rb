# frozen_string_literal: true

module Gustwave
  class Component < ViewComponent::Base
    include Primer::FetchOrFallbackHelper
    include Gustwave::Styleable
    include Gustwave::Themeable
    include TailwindHelper

    # Returns safe joined slots and content.
    #
    # @param slots [Array<Object>] slots to render
    # @param append_content [Boolean] whether to append the component's content (block) to the end of the slots. Defaults to true. Customize where and if the content block appears by passing it in the +slots+ array and setting +append_content+ to false.
    # @return [String] the safe joined slots and content (block)
    def slots_and_content(*slots, append_content: true)
      slots = slots.append(content) if append_content
      safe_join(slots.compact)
    end

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
      if !overwrite_class_attr && !overwrite_attrs.dig(:class).nil?
        overwrite_attrs[:class] = styles(
          custom_attribute_classes: default_attrs.dig(:class),
          custom_override_classes: overwrite_attrs.dig(:class)
        )
      end

      default_attrs.merge(overwrite_attrs)
    end
    alias configure_component configure_html_attributes

    def normalize_keys(options)
      normalized_options = {}

      options.each do |key, value|
        normalized_key = key.to_s.downcase.gsub("_", "-")

        if %w[aria data].include?(key) && value.is_a?(Hash)
          value.each do |sub_key, sub_value|
            normalized_options["#{key}-#{sub_key.to_s.downcase}"] = sub_value
          end
        else
          normalized_options[normalized_key] = value
        end
      end

      normalized_options.deep_symbolize_keys!
    end

    def lightswitch_cast(value)
      return value if [ :on, :off ].include?(value)
      return value.to_sym if %w[on off].include?(value)
      fetch_or_fallback_boolean(value, false)
    end

    # Generates a random ID with an optional prefix, postfix, and customizable
    # length.
    #
    # This can be useful when you want to automatically generate a default value
    # for the HTML id attribute.
    #
    # === Example
    #   random_id(prefix: "user", length: 8)
    #   # => "user-x3f9gk2j"
    #
    # @param prefix [String, nil] Optional string to prepend to the ID.
    # @param postfix [String, nil] Optional string to append to the ID.
    # @param length [Integer] The length of the random alphanumeric string. Default is 5.
    # @return [String] A random ID in the format: "prefix-randomstring-postfix".
    def random_id(prefix: nil, postfix: nil, length: 5)
      [ prefix, SecureRandom.alphanumeric(length).downcase, postfix ]
        .compact
        .join("-")
    end

    # Returns the provided text, @text or the component's content (block).
    # If `eval_content` is true, evaluates the content to ensure slots are
    # rendered.
    #
    # @param text [String, nil] the text to return if provided
    # @param eval_content [Boolean] whether to evaluate the content (block)
    # @return [String] text takes precedent over @text, over the content (block)
    def text_or_content(text: nil, eval_content: true)
      # We must eval content when the component defines a slot, otherwise the
      # slots are not rendered.
      content if eval_content

      text.presence || @text.presence || content
    end
  end
end
