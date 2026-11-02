# frozen_string_literal: true

require "cgi"
require "fileutils"
require "uri"
require_relative "flowbite_inventory"

module Gustwave
  # Turns the examples of one Flowbite docs page into static HTML pages that
  # render the way Flowbite's docs render them in their iframe, plus the CSS and
  # JS those pages need. Developer tool only, run it as
  # `ruby script/flowbite_examples.rb PAGE OUT_DIR APP_ROOT`. It only parses the
  # downloaded Markdown and never executes it, except for the static HTML pages
  # it writes.
  module FlowbiteExamples
    extend self

    Example = Struct.new(:id, :html, :wrapper_class, :body_class, :init_js, keyword_init: true)

    BLOCK = /\{\{<\s*example\b(.*?)>\}\}\n?(.*?)\{\{<\s*\/example\s*>\}\}/m
    ID = /(?<![A-Za-z])id="([^"]+)"/
    CLASS = /(?<![A-Za-z])class="([^"]*)"/
    BODY_CLASS = /bodyClass="([^"]*)"/
    DISABLE_INIT_JS = /disable_init_js="?true\b/

    # Opens the first overlay of each kind. Only added when the example has init_js.
    OPEN_OVERLAYS = <<~JS
      var dropdownEl = document.querySelector('[data-dropdown-toggle]'); if (dropdownEl) { dropdownEl.click(); }
      var modalEl = document.querySelector('[data-modal-toggle]'); if (modalEl) { modalEl.click(); }
      var drawerEl = document.querySelector('[data-drawer-show]'); if (drawerEl) { drawerEl.click(); }
    JS

    INIT_SCRIPT = <<~JS
      window.onload = function () {
        document.querySelectorAll('a').forEach(function (a) { a.addEventListener('click', function (ev) { ev.preventDefault(); }); });
        %s};
    JS

    INPUT_CSS = <<~CSS
      @import 'tailwindcss';
      @import '%<root>s/node_modules/flowbite/src/themes/default';
      @plugin '%<root>s/node_modules/flowbite/plugin';
      @source './examples';
      @source '%<root>s/node_modules/flowbite/dist/flowbite.min.js';
      @custom-variant dark (&:where(.dark, .dark *));
    CSS

    # The examples in a docs page, in order of appearance.
    def parse(markdown)
      seen = []

      markdown.scan(BLOCK).each_with_index.map do |(attributes, html), index|
        # Same rule as FlowbiteInventory, so the ids agree with lookbook/flowbite.yml.
        id = attributes[ID, 1] || "example-#{index}"
        id = "#{id}-#{seen.size}" if seen.include?(id)
        seen << id

        Example.new(
          id: id,
          html: html,
          wrapper_class: attributes[CLASS, 1].to_s.strip,
          body_class: attributes[BODY_CLASS, 1].to_s,
          init_js: !DISABLE_INIT_JS.match?(attributes)
        )
      end
    end

    def page_html(example)
      body_class = CGI.escapeHTML(example.body_class)
      wrapper_class = CGI.escapeHTML(example.wrapper_class)
      open_overlays = example.init_js ? OPEN_OVERLAYS : ""

      <<~HTML
        <!DOCTYPE html>
        <html lang="en"><head><meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
        <link rel="stylesheet" href="../flowbite.css"></head>
        <body class="p-5 bg-white dark:bg-gray-900 antialiased #{body_class}"><div id="exampleWrapper" class="#{wrapper_class}">
        #{example.html}
        </div>
        <script src="../flowbite.min.js"></script>
        <script>#{format(INIT_SCRIPT, open_overlays)}</script>
        </body></html>
      HTML
    end

    # Writes one page per example to out_dir/examples and returns how many.
    def write_pages(markdown, out_dir)
      examples = parse(markdown)
      dir = File.join(out_dir, "examples")
      FileUtils.mkdir_p(dir)

      examples.each do |example|
        File.write(File.join(dir, "#{example.id}.html"), page_html(example), encoding: "utf-8")
      end
      examples.size
    end

    # Writes the Tailwind input and compiles it to out_dir/flowbite.css, and
    # copies Flowbite's JS next to the pages. app_root is an absolute path.
    def build_assets(out_dir, app_root:)
      FileUtils.mkdir_p(out_dir)
      input = File.join(out_dir, "input.css")
      output = File.join(out_dir, "flowbite.css")

      File.write(input, format(INPUT_CSS, root: app_root), encoding: "utf-8")
      system("tailwindcss", "-i", input, "-o", output, exception: true)
      FileUtils.cp(File.join(app_root, "node_modules/flowbite/dist/flowbite.min.js"), File.join(out_dir, "flowbite.min.js"))
    end

    # The Markdown of a docs page at the pinned tag, e.g. "components/dropdowns".
    # Only reads the Markdown, it is never executed.
    def download(page)
      source = IconImport.parse_source(FlowbiteInventory::DEFAULT_SOURCE)
      IconImport.http_get(URI(IconImport.raw_url(source, "content/#{page}.md")))
    end
  end
end

if $PROGRAM_NAME == __FILE__
  unless ARGV.size == 3
    warn "usage: ruby flowbite_examples.rb PAGE OUT_DIR APP_ROOT"
    exit 1
  end

  page, out_dir, app_root = ARGV
  count = Gustwave::FlowbiteExamples.write_pages(Gustwave::FlowbiteExamples.download(page), out_dir)
  Gustwave::FlowbiteExamples.build_assets(out_dir, app_root:)
  puts "examples written: #{count}"
end
