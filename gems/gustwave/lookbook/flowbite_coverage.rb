# frozen_string_literal: true

require "yaml"

module Gustwave
  # A read-only view of lookbook/flowbite.yml for Lookbook's coverage pages. Only
  # loaded alongside Lookbook, see config/initializers/lookbook.rb in the host
  # application. Never shipped with the gem.
  class FlowbiteCoverage
    MANIFEST = File.expand_path("flowbite.yml", __dir__)
    DOCS_URL = "https://flowbite.com/docs"
    SOURCE_URL = "https://github.com/themesberg/flowbite/blob"
    STATUSES = {
      "previewed" => "Has a preview",
      "composable" => "Composable",
      "tailwind" => "Plain Tailwind",
      "feature_gap" => "Feature missing",
      "partial" => "Partial",
      "blocked" => "Blocked",
      "out_of_scope" => "Out of scope"
    }.freeze
    POSSIBLE = %w[previewed composable tailwind].freeze

    Example = Struct.new(:page, :id, :title, :status, :preview, :params, :needs, :note, keyword_init: true) do
      def preview_path
        File.dirname(preview) if preview
      end

      def scenario
        File.basename(preview) if preview
      end

      def status_label
        STATUSES.fetch(status)
      end

      # Flowbite's docs always show its latest release, unlike #source_url.
      def docs_url
        anchor = title.split(" > ").last.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "")
        "#{DOCS_URL}/#{page}/##{anchor}"
      end
    end

    class << self
      # The manifest, read again when it changes.
      def current
        mtime = File.mtime(MANIFEST)
        return @current if @current && @mtime == mtime

        @mtime = mtime
        @current = new(YAML.safe_load(File.read(MANIFEST, encoding: "utf-8")))
      end
    end

    attr_reader :version

    def initialize(manifest)
      @version = manifest.fetch("flowbite_version")
      @pages = manifest.fetch("pages").to_h do |page, entries|
        [ page, entries.map { |entry| Example.new(page:, **entry.transform_keys(&:to_sym)) } ]
      end
    end

    def page_keys
      @pages.keys
    end

    def examples(page = nil)
      page ? @pages.fetch(page) : @pages.values.flatten
    end

    # The number of examples per status, in the order of STATUSES.
    def totals(page = nil)
      counts = examples(page).map(&:status).tally
      STATUSES.keys.to_h { |status| [ status, counts.fetch(status, 0) ] }
    end

    def possible_count
      totals.values_at(*POSSIBLE).sum
    end

    def in_scope_count
      examples.size - totals.fetch("out_of_scope")
    end

    # What examples are waiting for, most wanted first, as hashes with the need,
    # the number of examples and the pages they are on.
    def gaps
      waiting = examples.select(&:needs).group_by(&:needs).map do |need, group|
        { need:, count: group.size, pages: group.map(&:page).uniq }
      end
      waiting.sort_by { |gap| [ -gap[:count], gap[:need] ] }
    end

    # The examples a scenario reproduces, given its path, e.g. "gustwave/tabs/default".
    def for_scenario(path)
      examples.select { |example| example.preview == path }
    end

    def docs_url(page)
      "#{DOCS_URL}/#{page}/"
    end

    def source_url(page)
      "#{SOURCE_URL}/v#{version}/content/#{page}.md"
    end
  end
end
