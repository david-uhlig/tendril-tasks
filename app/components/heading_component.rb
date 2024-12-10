# frozen_string_literal: true

class HeadingComponent < ApplicationComponent
  DEFAULT_TAG = :h2
  TAG_OPTIONS = [ :h1, :h2, :h3, :h4, :h5, :h6 ].freeze

  DEFAULT_SCHEME = :primary
  SCHEME_MAPPINGS = {
    :none => "",
    DEFAULT_SCHEME => "group mb-4 text-4xl font-extrabold leading-none tracking-tight text-gray-900 md:text-5xl lg:text-6xl dark:text-white",
    :secondary => "group mb-4 text-3xl font-extrabold leading-none tracking-tight text-gray-900 md:text-4xl lg:text-5xl dark:text-white",
    :tertiary => "group mb-4 text-2xl font-bold leading-none tracking-tight text-gray-900 md:text-3xl lg:text-4xl dark:text-white",
    :quaternary => "",
    :quinary => "",
    :senary => ""
  }.freeze
  SCHEME_OPTIONS = SCHEME_MAPPINGS.keys

  def initialize(tag:, scheme: DEFAULT_SCHEME, text: nil, **options)
    @tag = fetch_or_fallback(TAG_OPTIONS, tag, DEFAULT_TAG)
    @scheme = fetch_or_fallback(SCHEME_OPTIONS, scheme, DEFAULT_SCHEME)
    @text = text
    @options = build_options(options)
  end

  def call
    content_tag @tag, **@options do
      @text || content
    end
  end

  private

  def before_render
    @options[:id] ||= helpers.strip_tags(@text || content).parameterize
  end

  def build_options(options)
    options.stringify_keys!
    options["class"] = class_names(
      SCHEME_MAPPINGS[@scheme],
      options.delete("class")
    )
    options.symbolize_keys!
    options
  end
end
