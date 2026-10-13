# frozen_string_literal: true

require "date"
require "rubygems"

module Release
  # Reads and rewrites CHANGELOG.md, which follows Keep a Changelog with one
  # `## [x.y.z] - date` section per release and link references at the end.
  class Changelog
    class Error < StandardError; end

    REPOSITORY = "https://github.com/david-uhlig/tendril-tasks"
    UNRELEASED = "Unreleased"
    # The order of the subsections within a release
    HEADINGS = [ "Breaking Changes", "Deprecated", "Added", "Changed", "Removed", "Fixed", "Security" ].freeze
    # The only subsections a patch release may contain
    PATCH_HEADINGS = [ "Fixed", "Security" ].freeze

    SECTION = /\A## \[(?<name>[^\]]+)\]/
    SUBSECTION = /\A### (?<heading>.+)\z/
    LINK = /\A\[(?<name>[^\]]+)\]: (?<url>\S+)\z/

    Section = Struct.new(:heading, :body) do
      def name = heading[SECTION, :name]
      def version
        Gem::Version.new(name) unless name == UNRELEASED
      end
    end

    def self.parse(text) = new(text)

    def initialize(text)
      lines = text.lines(chomp: true)
      @links = lines.select { |line| line.match?(LINK) }
      lines -= @links

      first = lines.index { |line| line.match?(SECTION) } || lines.size
      @preamble = strip_blank(lines[0...first])
      @sections = lines[first..].slice_before { |line| line.match?(SECTION) }.map do |heading, *body|
        Section.new(heading, strip_blank(body))
      end
    end

    def to_s
      lines = @preamble + [ "" ]
      @sections.each do |section|
        lines << section.heading << ""
        lines.concat(section.body, [ "" ]) if section.body.any?
      end
      (lines + @links).join("\n") + "\n"
    end

    def versions = @sections.filter_map(&:version)

    # The GitHub release notes of a version: its section under "What's Changed"
    # and a link that compares it to the previous release
    def notes(version)
      lines = [ "## What's Changed", "", *fetch(version).body ]
      previous = versions.select { |existing| existing < Gem::Version.new(version) }.max
      lines.push("", "**Full Changelog**: #{REPOSITORY}/compare/v#{previous}...v#{version}") if previous
      lines.join("\n")
    end

    # The entries of a section by subsection, e.g. { "Fixed" => ["- Fix ..."] }.
    # Lines indented below a `- ` line belong to its entry. Repeated
    # subsections are merged.
    def entries(name = UNRELEASED)
      result = {}
      current = nil
      fetch(name).body.each do |line|
        if (match = line.match(SUBSECTION))
          current = result[match[:heading]] ||= []
        elsif line.start_with?("- ") && current
          current << line
        elsif line.match?(/\A\s+\S/) && current&.any?
          current[-1] = "#{current.last}\n#{line}"
        end
      end
      result.reject { |_, list| list.empty? }
    end

    # Subsections in [Unreleased] that a patch release must not contain
    def non_patch_headings = entries.keys - PATCH_HEADINGS

    # Turns [Unreleased] into a section for `version` and starts a new, empty
    # [Unreleased] section.
    def release(version, date: Date.today)
      unreleased = fetch(UNRELEASED)
      raise Error, "[Unreleased] has no entries to release" if entries.empty?
      raise Error, "#{version} is already in the changelog" if find(version)

      previous = link(UNRELEASED)&.[](%r{/compare/v(.+)\.\.\.HEAD\z}, 1)
      raise Error, "Can't find the previous version in the [unreleased] link" unless previous

      @sections.insert(@sections.index(unreleased) + 1, Section.new("## [#{version}] - #{date.iso8601}", unreleased.body))
      unreleased.body = []
      set_link(UNRELEASED, "#{REPOSITORY}/compare/v#{version}...HEAD")
      set_link(version, "#{REPOSITORY}/compare/v#{previous}...v#{version}")
      self
    end

    # Copies the section of `version` from `other`, e.g. the changelog of a
    # patch release on a stable branch, and removes its entries from
    # [Unreleased]. Returns the entries it couldn't find in [Unreleased].
    def add_release(other, version)
      section = other.fetch(version)
      unless find(version)
        index = @sections.index { |existing| existing.version && existing.version < section.version } || @sections.size
        @sections.insert(index, Section.new(section.heading, section.body.dup))
      end
      set_link(version, other.link(version)) if other.link(version)

      other.entries(version).values.flatten.reject { |entry| remove_unreleased(entry) }
    end

    # Adds entries to [Unreleased], e.g. those of a backported commit
    def add_unreleased(new_entries)
      merged = entries
      new_entries.each do |heading, list|
        merged[heading] = (merged.fetch(heading, []) + list).uniq
      end
      write_unreleased(merged)
      self
    end

    # The entries a commit added to [Unreleased], from the changelog before and
    # after the commit
    def self.added_entries(before, after)
      previous = parse(before).entries
      parse(after).entries.to_h { |heading, list| [ heading, list - previous.fetch(heading, []) ] }.reject { |_, list| list.empty? }
    end

    def link(name)
      @links.find { |line| line[LINK, :name].casecmp?(name.to_s) }&.[](LINK, :url)
    end

    protected

    def fetch(name)
      find(name) || raise(Error, "[#{name}] is not in the changelog")
    end

    private

    def find(name)
      @sections.find { |section| section.name.casecmp?(name.to_s) }
    end

    def remove_unreleased(entry)
      remaining = entries
      list = remaining.values.find { |candidates| candidates.include?(entry) }
      return false unless list

      list.delete(entry)
      write_unreleased(remaining)
      true
    end

    def write_unreleased(by_heading)
      ordered = by_heading.reject { |_, list| list.empty? }.sort_by { |heading, _| HEADINGS.index(heading) || HEADINGS.size }
      fetch(UNRELEASED).body = ordered.flat_map { |heading, list| [ "### #{heading}", *list.flat_map { |entry| entry.split("\n") }, "" ] }[0...-1]
    end

    # Keeps [unreleased] first and the versions in descending order
    def set_link(name, url)
      line = "[#{name.to_s.downcase}]: #{url}"
      @links.reject! { |existing| existing[LINK, :name].casecmp?(name.to_s) }
      return @links.unshift(line) if name.to_s.casecmp?(UNRELEASED)

      version = Gem::Version.new(name)
      index = @links.index do |existing|
        existing_name = existing[LINK, :name]
        Gem::Version.correct?(existing_name) && Gem::Version.new(existing_name) < version
      end
      @links.insert(index || @links.size, line)
    end

    def strip_blank(lines)
      lines.drop_while(&:empty?).reverse.drop_while(&:empty?).reverse
    end
  end
end
