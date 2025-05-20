# frozen_string_literal: true

module Gustwave
  module HtmlAttributesHelper
    # Normalizes HTML attributes equivalent to +content_tag+.
    #
    # Symbolizes keys and transforms keys nested within +aria+ and +data+
    # objects into +aria-+ and +data-+ prefixed attributes.
    #
    # Underscored keys within +aria+ and +data+ objects are hyphenated
    #
    # === Examples
    #
    #   normalize_html_attributes(aria: { labelledby: "foo" })
    #   # => { "aria-labelledby": "foo" }
    #
    #   normalize_html_attributes(data: { hello_target: "output" })
    #   # => { "data-hello-target": "output" }
    #
    #   # Caution: First level attributes are not hyphenated!
    #   normalize_html_attributes(accept_charset: "UTF-8")
    #   # => { accept_charset: "UTF-8" }
    #
    # @param options [Hash] the options hash to normalize.
    def normalize_html_attributes(**options)
      options = options.symbolize_keys
      %i[aria data].each do |key|
        next unless options.fetch(key, nil).is_a?(Hash)

        options[key].each do |sub_key, sub_value|
          options["#{key}-#{sub_key.to_s.downcase.tr("_", "-")}".to_sym] = sub_value
        end
        options.delete(key)
      end

      options
    end

    # Generates a random +id+  with an optional prefix, postfix, customizable
    # length, and separator.
    #
    # Useful for generating unique +id+s for components that have multiple parts,
    # who interact with each other, e.g. Gustwave::Dropdown.
    #
    # === Example
    # Generate a random id with a prefix, where the random part is 8 characters
    # long:
    #
    #   generate_random_id(prefix: "dropdown-menu", length: 8)
    #   # => "dropdown-menu-x3f9gk2j"
    #
    # @param prefix [String, NilClass] String prepended to the random part of the id. (Optional)
    # @param postfix [String, NilClass] String appended to the random part of the id. (Optional)
    # @param length [Integer] Length of the random part of the id. Defaults to 8 characters.
    # @param separator [String] Separator between the prefix, random part, and postfix. Defaults to "-".
    def generate_random_id(prefix: nil, postfix: nil, length: 8, separator: "-")
      [ prefix, SecureRandom.alphanumeric(length).downcase, postfix ]
        .compact_blank
        .join(separator)
    end
  end
end
