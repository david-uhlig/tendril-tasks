# frozen_string_literal: true

require "json"
require "optparse"
require "uri"
require "yaml"
require_relative "icon_import"

module Gustwave
  # Keeps lookbook/flowbite.yml in step with a Flowbite release. The manifest
  # lists every example in Flowbite's docs and how far Gustwave covers it.
  # Developer tool only, run it through bin/flowbite-inventory. It only parses
  # the downloaded Markdown and never executes any of it.
  module FlowbiteInventory
    extend self

    Error = IconImport::Error

    # Pinned to a release. To upgrade, bump the tag, run --dry-run, then run it
    # for real and classify the examples it added.
    DEFAULT_SOURCE = "https://github.com/themesberg/flowbite/tree/v3.1.2/content"
    SECTIONS = %w[components forms typography plugins].freeze
    MANIFEST = File.expand_path("../lookbook/flowbite.yml", __dir__)
    UNCLASSIFIED = "unclassified"
    # Loose on purpose: the shortcode can be indented, and its attributes can
    # continue on the following lines.
    EXAMPLE = /\{\{<\s*example\b(.*)/
    HEADING = /\A(\#\#\#?) (.+)/
    HEADER = <<~YAML
      # Every example in Flowbite's docs and how far Gustwave covers it. After
      # bumping the tag in script/flowbite_inventory.rb, run bin/flowbite-inventory
      # and classify what it added. spec/lookbook/flowbite_coverage_spec.rb checks
      # this file.
    YAML

    # The examples in a docs page, as hashes with an id and a title.
    def parse(markdown)
      heading = subheading = nil
      seen = []

      markdown.each_line.with_object([]) do |line, examples|
        if (match = HEADING.match(line.chomp))
          if match[1] == "##"
            heading = match[2].strip
            subheading = nil
          else
            subheading = match[2].strip
          end
        end

        match = EXAMPLE.match(line) or next

        id = match[1][/\bid="([^"]+)"/, 1] || slug(heading)
        id = "#{id}-#{seen.size}" if seen.include?(id)
        seen << id
        examples << { "id" => id, "title" => [ heading, subheading ].compact.join(" > ") }
      end
    end

    # Maps "section/page" to the examples of every page that has any.
    def fetch_pages(source)
      page_paths(source).to_h do |page, path|
        [ page, parse(IconImport.http_get(URI(IconImport.raw_url(source, path)))) ]
      end.reject { |_page, examples| examples.empty? }
    end

    # Applies the upstream examples to the current pages. Known examples keep
    # their status, new ones are unclassified and removed ones are dropped.
    # Returns the pages and what changed.
    def merge(current, upstream)
      changes = { added: [], removed: [], retitled: [] }

      pages = upstream.to_h do |page, examples|
        known = current.fetch(page, []).to_h { |entry| [ entry["id"], entry ] }

        entries = examples.map do |example|
          entry = known[example["id"]]
          key = "#{page}##{example["id"]}"

          if entry.nil?
            changes[:added] << key
            example.merge("status" => UNCLASSIFIED)
          else
            changes[:retitled] << key if entry["title"] != example["title"]
            entry.merge("title" => example["title"])
          end
        end

        [ page, entries ]
      end

      current.each do |page, entries|
        ids = pages.fetch(page, []).map { |entry| entry["id"] }
        entries.each { |entry| changes[:removed] << "#{page}##{entry["id"]}" unless ids.include?(entry["id"]) }
      end

      [ pages, changes ]
    end

    # The version a source is pinned to, e.g. "3.1.2".
    def version(source = IconImport.parse_source(DEFAULT_SOURCE))
      source[:ref].delete_prefix("v")
    end

    def read_manifest(path = MANIFEST)
      return { "pages" => {} } unless File.exist?(path)

      YAML.safe_load(File.read(path, encoding: "utf-8"))
    end

    def dump_manifest(version, pages)
      HEADER + { "flowbite_version" => version, "pages" => pages }.to_yaml(line_width: -1)
    end

    private

    def slug(heading)
      heading.to_s.downcase.gsub(/[^a-z0-9]+/, "-").gsub(/\A-|-\z/, "")
    end

    # Maps "section/page" to the repository path of every docs page.
    def page_paths(source)
      uri = URI("https://api.github.com/repos/#{source[:owner]}/#{source[:repo]}/git/trees/#{source[:ref]}?recursive=1")
      headers = { "Accept" => "application/vnd.github+json", "User-Agent" => "gustwave-flowbite-inventory" }
      token = IconImport.github_token
      headers["Authorization"] = "Bearer #{token}" if token

      data = JSON.parse(IconImport.http_get(uri, headers))
      raise Error, "GitHub tree listing was truncated, the source is too large for one request" if data["truncated"]

      paths = data.fetch("tree").filter_map { |entry| entry["path"] if entry["type"] == "blob" }

      SECTIONS.flat_map do |section|
        paths.select { |path| File.dirname(path) == "#{source[:root]}/#{section}" && path.end_with?(".md") }
             .sort
             .map { |path| [ "#{section}/#{File.basename(path, ".md")}", path ] }
      end
    end

    # Command line interface. Returns the process exit status.
    class CLI
      def initialize(argv, out: $stdout, err: $stderr, manifest: MANIFEST)
        @argv = argv
        @out = out
        @err = err
        @manifest = manifest
      end

      def run
        options = { source: DEFAULT_SOURCE }
        parser = option_parser(options)
        arguments = parser.parse(@argv)
        raise Error, "takes no arguments, got #{arguments.join(" ")}" if arguments.any?

        source = IconImport.parse_source(options[:source])
        current = FlowbiteInventory.read_manifest(@manifest).fetch("pages")
        pages, changes = FlowbiteInventory.merge(current, FlowbiteInventory.fetch_pages(source))

        report(pages, changes)
        unless options[:dry_run]
          File.write(@manifest, FlowbiteInventory.dump_manifest(FlowbiteInventory.version(source), pages), encoding: "utf-8")
        end
        0
      rescue Error, OptionParser::ParseError => e
        @err.puts "flowbite-inventory: #{e.message}"
        1
      end

      private

      def option_parser(options)
        OptionParser.new do |o|
          o.banner = "Usage: flowbite-inventory [--dry-run] [--source URL]"
          o.on("--dry-run", "Report changes without writing them") { options[:dry_run] = true }
          o.on("--source URL", "GitHub tree URL of Flowbite's docs content") { |v| options[:source] = v }
        end
      end

      def report(pages, changes)
        changes.each do |change, keys|
          keys.each { |key| @out.puts "#{change} #{key}" }
        end
        counts = changes.map { |change, keys| "#{change} #{keys.size}" }.join(", ")
        @out.puts "pages #{pages.size}, examples #{pages.values.sum(&:size)}: #{counts}"
      end
    end
  end
end
