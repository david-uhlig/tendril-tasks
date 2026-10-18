# frozen_string_literal: true

require "json"
require "net/http"
require "open3"
require "optparse"
require "uri"

module Gustwave
  # Imports Flowbite icons (https://github.com/themesberg/flowbite-icons) into
  # the gem's icon folders. Developer tool only, run it through bin/import-icon.
  module IconImport
    extend self

    class Error < StandardError; end

    # Pinned to a release. To upgrade, bump the tag, then run --reimport --dry-run and --new --dry-run.
    DEFAULT_SOURCE = "https://github.com/themesberg/flowbite-icons/tree/v1.5.0/src"
    THEMES = %w[outline solid].freeze
    # Icons that are not from Flowbite and must never be compared with upstream.
    LOCAL_ONLY = %w[outline/spinner.svg].freeze
    # Upstream icons deliberately not imported. --new and --reimport skip them.
    EXCLUDED = %w[].freeze
    ICONS_DIR = File.expand_path("../app/assets/images/gustwave/icons", __dir__)
    NAME_PATTERN = /\A[a-z0-9]+(?:-[a-z0-9]+)*\z/
    TREE_URL = %r{\Ahttps://github\.com/([^/]+)/([^/]+)/tree/([^/]+)(?:/(.*))?\z}
    BLOB_URL = %r{\Ahttps://github\.com/([^/]+)/([^/]+)/blob/([^/]+)/(.+)\z}

    Request = Struct.new(:theme, :name, :url, :file, keyword_init: true)

    # Converts an upstream Flowbite SVG to the form stored in Gustwave.
    # Plain string substitution on purpose, so the file is not reformatted.
    def convert(svg, theme:)
      text = svg
      text = text.sub("<svg ", '<svg aria-hidden="true" ') unless root_tag(text).include?("aria-hidden=")
      text = text.gsub('stroke-width="2"', 'stroke-width="1.5"') if theme == "outline"
      text.rstrip + "\n"
    end

    # Raises Error unless the upstream SVG has the shape convert expects.
    def validate!(svg, theme:)
      root = root_tag(svg)
      raise Error, "no <svg> root element found" if root.empty?

      view_box = root[/\sviewBox="([^"]*)"/, 1]
      raise Error, %(expected viewBox="0 0 24 24" on the root <svg>, got #{view_box.inspect}) unless view_box == "0 0 24 24"

      if theme == "outline"
        widths = stroke_widths(svg)
        invalid = widths.uniq.reject { |width| width.match?(/\A\d+(\.\d+)?\z/) }
        raise Error, "unexpected stroke-width #{invalid.join(", ")} (expected a number)" if invalid.any?
        # Some outline icons are drawn with filled paths and have no stroke-width at all.
        if widths.empty? && !svg.include?('fill="currentColor"')
          raise Error, 'outline icon has no stroke-width and no fill="currentColor"'
        end
      elsif !svg.include?('fill="currentColor"') && !svg.include?('stroke="currentColor"')
        raise Error, 'solid icon must use fill="currentColor" or stroke="currentColor"'
      end

      svg
    end

    # Problems with an already converted local icon. Used by --check.
    def violations(svg, theme:)
      problems = []
      problems << 'missing aria-hidden="true" on <svg>' unless root_tag(svg).include?("aria-hidden=")
      if theme == "outline" && stroke_widths(svg).include?("2")
        problems << 'stroke-width="2" was not converted to "1.5"'
      end
      problems
    end

    # Splits a GitHub tree URL into the parts needed for the API and raw URLs.
    def parse_source(url)
      match = TREE_URL.match(url)
      raise Error, "unsupported source #{url}: expected https://github.com/OWNER/REPO/tree/REF/PATH" unless match

      { owner: match[1], repo: match[2], ref: match[3], root: match[4].to_s.delete_suffix("/") }
    end

    # Maps [theme, name] to the repository path of every SVG under the source root.
    def build_index(source)
      uri = URI("https://api.github.com/repos/#{source[:owner]}/#{source[:repo]}/git/trees/#{source[:ref]}?recursive=1")
      headers = { "Accept" => "application/vnd.github+json", "User-Agent" => "gustwave-import-icon" }
      token = github_token
      headers["Authorization"] = "Bearer #{token}" if token

      data = JSON.parse(http_get(uri, headers))
      raise Error, "GitHub tree listing was truncated, the source is too large for one request" if data["truncated"]

      prefix = source[:root].empty? ? "" : "#{source[:root]}/"
      data.fetch("tree").each_with_object({}) do |entry, index|
        path = entry["path"]
        next unless entry["type"] == "blob" && path.start_with?(prefix) && path.end_with?(".svg")

        theme = path.delete_prefix(prefix).split("/").first
        next unless THEMES.include?(theme)

        index[[ theme, File.basename(path, ".svg") ]] = path
      end
    end

    # Turns a CLI argument (name, THEME/CATEGORY/NAME path, blob URL or local
    # .svg file) into a Request. The index maps [theme, name] to repository paths.
    def resolve(arg, theme:, index:, source:)
      if (match = BLOB_URL.match(arg))
        owner, repo, ref, path = match.captures
        raise Error, "not an .svg file: #{arg}" unless path.end_with?(".svg")

        icon_theme = path.delete_prefix("src/").split("/").first
        raise Error, "cannot tell the theme from #{arg}" unless THEMES.include?(icon_theme)

        return Request.new(theme: icon_theme, name: File.basename(path, ".svg"),
                           url: "https://raw.githubusercontent.com/#{owner}/#{repo}/#{ref}/#{path}")
      end

      if arg.end_with?(".svg") && File.file?(arg)
        return Request.new(theme: theme, name: File.basename(arg, ".svg"), file: arg)
      end

      name_path = arg.delete_prefix("src/").delete_suffix(".svg")
      if name_path.include?("/")
        segments = name_path.split("/")
        theme = segments.first
        raise Error, "expected THEME/CATEGORY/NAME, got #{arg}" unless segments.size == 3 && THEMES.include?(theme)

        name = segments.last
        expected = [ source[:root], "#{name_path}.svg" ].reject(&:empty?).join("/")
        raise Error, "#{arg} not found upstream" unless index[[ theme, name ]] == expected
      else
        name = name_path
        raise Error, "no #{theme} icon named #{name} upstream" unless index[[ theme, name ]]
      end

      Request.new(theme: theme, name: name, url: raw_url(source, index[[ theme, name ]]))
    end

    def raw_url(source, path)
      "https://raw.githubusercontent.com/#{source[:owner]}/#{source[:repo]}/#{source[:ref]}/#{path}"
    end

    # The upstream folder of an indexed path, e.g. "arrows" or "food:beverage".
    def category(path)
      File.basename(File.dirname(path))
    end

    def fetch_svg(request)
      request.file ? File.read(request.file) : http_get(URI(request.url))
    end

    def root_tag(svg)
      svg[/<svg\b[^>]*>/] || ""
    end

    def stroke_widths(svg)
      svg.scan(/stroke-width="([^"]*)"/).flatten
    end

    def http_get(uri, headers = {}, redirects = 5)
      response = Net::HTTP.get_response(uri, headers)
      case response
      when Net::HTTPSuccess
        response.body.dup.force_encoding(Encoding::UTF_8)
      when Net::HTTPRedirection
        raise Error, "too many redirects fetching #{uri}" if redirects.zero?

        http_get(URI(response["location"]), headers, redirects - 1)
      else
        raise Error, "GET #{uri} failed: #{response.code} #{response.message}"
      end
    end

    # The token only raises the API rate limit, so a missing one is fine.
    def github_token
      token = ENV["GITHUB_TOKEN"].to_s
      return token unless token.empty?

      output, status = Open3.capture2("gh", "auth", "token", err: File::NULL)
      token = output.strip
      status.success? && !token.empty? ? token : nil
    rescue SystemCallError
      nil
    end

    # Command line interface. Returns the process exit status.
    class CLI
      def initialize(argv, out: $stdout, err: $stderr, icons_dir: ICONS_DIR)
        @argv = argv
        @out = out
        @err = err
        @icons_dir = icons_dir
      end

      def run
        options = { source: DEFAULT_SOURCE }
        parser = option_parser(options)
        names = parser.parse(@argv)

        if options[:new] || options[:reimport] || options[:check]
          raise Error, "use only one of --new, --reimport and --check" if %i[new reimport check].count { |mode| options[mode] } > 1
          raise Error, "--new, --reimport and --check take no icon arguments" if names.any?

          if options[:new]
            new_icons(options)
          elsif options[:reimport]
            reimport(options)
          else
            check
          end
        elsif names.any?
          import(names, options)
          0
        else
          @err.puts parser.help
          1
        end
      rescue Error => e
        @err.puts "import-icon: #{e.message}"
        1
      end

      private

      def option_parser(options)
        OptionParser.new do |o|
          o.banner = <<~USAGE.chomp
            Usage: import-icon <name|path|url>... [--theme THEME] [--as NAME] [--force] [--source URL]
                   import-icon --new [--theme THEME] [--category NAME] [--only GLOB] [--dry-run] [--source URL]
                   import-icon --reimport [--dry-run] [--source URL]
                   import-icon --check
          USAGE
          o.on("--theme THEME", THEMES, "Theme for bare names and local files (default: outline); with --new, limits it to one theme") { |v| options[:theme] = v }
          o.on("--as NAME", "Save the icon under NAME (single icon only)") { |v| options[:as] = v }
          o.on("--force", "Overwrite an existing icon") { options[:force] = true }
          o.on("--source URL", "GitHub tree URL to import from") { |v| options[:source] = v }
          o.on("--new", "Import every upstream icon that is not local yet") { options[:new] = true }
          o.on("--category NAME", "With --new, only icons from this upstream folder (e.g. arrows)") { |v| options[:category] = v }
          o.on("--only GLOB", "With --new, only icons whose name matches GLOB") { |v| options[:only] = v }
          o.on("--reimport", "Re-fetch every local icon from upstream") { options[:reimport] = true }
          o.on("--dry-run", "With --new or --reimport, report changes without writing them") { options[:dry_run] = true }
          o.on("--check", "Check local icons for problems (offline)") { options[:check] = true }
        end
      end

      def import(args, options)
        raise Error, "--as can only be used with a single icon" if options[:as] && args.size > 1

        source = IconImport.parse_source(options[:source])
        index = IconImport.build_index(source)
        args.each do |arg|
          request = IconImport.resolve(arg, theme: options[:theme] || "outline", index: index, source: source)
          name = options[:as] || request.name
          raise Error, "invalid icon name #{name.inspect}" unless name.match?(NAME_PATTERN)

          path = File.join(@icons_dir, request.theme, "#{name}.svg")
          raise Error, "#{path} already exists (use --force to overwrite)" if File.exist?(path) && !options[:force]

          svg = IconImport.fetch_svg(request)
          IconImport.validate!(svg, theme: request.theme)
          File.write(path, IconImport.convert(svg, theme: request.theme))

          solid = request.theme == "solid" ? ", theme: :solid" : ""
          @out.puts path
          @out.puts "Gustwave::Icon.new(:#{name.tr("-", "_")}#{solid})"
        end
      end

      def new_icons(options)
        source = IconImport.parse_source(options[:source])
        index = IconImport.build_index(source)
        added = 0
        excluded = 0
        failed = 0

        index.keys.sort.each do |theme, name|
          path = index[[ theme, name ]]
          next if options[:theme] && theme != options[:theme]
          next if options[:category] && IconImport.category(path) != options[:category]
          next if options[:only] && !File.fnmatch(options[:only], name)

          key = "#{theme}/#{name}.svg"
          target = File.join(@icons_dir, theme, "#{name}.svg")
          next if File.exist?(target)

          if IconImport::EXCLUDED.include?(key)
            excluded += 1
            @out.puts "excluded #{key}"
            next
          end

          begin
            svg = IconImport.http_get(URI(IconImport.raw_url(source, path)))
            IconImport.validate!(svg, theme: theme)
            converted = IconImport.convert(svg, theme: theme)
            File.write(target, converted) unless options[:dry_run]
            added += 1
            @out.puts "#{options[:dry_run] ? "would add" : "added"} #{key}"
          rescue IconImport::Error => e
            failed += 1
            @err.puts "failed #{key}: #{e.message}"
          end
        end

        @out.puts "added #{added}, excluded #{excluded}, failed #{failed}"
        failed.zero? ? 0 : 1
      end

      def reimport(options)
        source = IconImport.parse_source(options[:source])
        index = IconImport.build_index(source)
        missing = false

        local_icons.each do |icon|
          if LOCAL_ONLY.include?(icon[:key])
            @out.puts "skipped #{icon[:key]}"
            next
          end

          if IconImport::EXCLUDED.include?(icon[:key])
            @out.puts "excluded #{icon[:key]}"
            next
          end

          upstream = index[[ icon[:theme], icon[:name] ]]
          unless upstream
            missing = true
            @out.puts "missing #{icon[:key]}"
            next
          end

          svg = IconImport.http_get(URI(IconImport.raw_url(source, upstream)))
          IconImport.validate!(svg, theme: icon[:theme])
          converted = IconImport.convert(svg, theme: icon[:theme])
          current = File.read(icon[:path])
          if converted == current
            @out.puts "unchanged #{icon[:key]}"
          else
            @out.puts "updated #{icon[:key]}"
            @out.puts line_diff(current, converted)
            File.write(icon[:path], converted) unless options[:dry_run]
          end
        end

        missing ? 1 : 0
      end

      def check
        problems = 0
        local_icons.each do |icon|
          next if LOCAL_ONLY.include?(icon[:key])

          IconImport.violations(File.read(icon[:path]), theme: icon[:theme]).each do |problem|
            @out.puts "#{icon[:key]}: #{problem}"
            problems += 1
          end
        end

        problems.zero? ? 0 : 1
      end

      def local_icons
        IconImport::THEMES.flat_map do |theme|
          Dir.glob(File.join(@icons_dir, theme, "*.svg")).sort.map do |path|
            name = File.basename(path, ".svg")
            { key: "#{theme}/#{name}.svg", theme: theme, name: name, path: path }
          end
        end
      end

      # A simple line diff, enough to see what changed in a one-path icon.
      def line_diff(old_text, new_text)
        old_lines = old_text.lines
        new_lines = new_text.lines
        lines = []
        [ old_lines.size, new_lines.size ].max.times do |i|
          next if old_lines[i] == new_lines[i]

          lines << "  -#{old_lines[i].chomp}" if old_lines[i]
          lines << "  +#{new_lines[i].chomp}" if new_lines[i]
        end
        lines.join("\n")
      end
    end
  end
end
