# frozen_string_literal: true

require "cgi"
require "json"
require "selenium-webdriver"
require "yaml"

module Gustwave
  # Developer tool: renders Flowbite examples and Gustwave previews in Chrome and
  # writes what differs for a person to judge. It never decides a verdict. Needs
  # the Lookbook server running on BASE_URL and the example files already built
  # into OUT_DIR. Run it by hand:
  #   bundle exec ruby gems/gustwave/script/flowbite_compare.rb PAGE OUT_DIR [BASE_URL]
  module FlowbiteCompare
    extend self

    Error = Class.new(StandardError)

    MANIFEST = File.expand_path("../lookbook/flowbite.yml", __dir__)
    BASE_URL = "http://127.0.0.1:3021"
    THEMES = %w[light dark].freeze
    STRATEGIES = { "components/alerts" => :static, "components/dropdowns" => :dropdown }.freeze
    USAGE = "Usage: bundle exec ruby gems/gustwave/script/flowbite_compare.rb PAGE OUT_DIR [BASE_URL]"
    CHROME_ARGS = %w[--headless=new --no-sandbox --disable-dev-shm-usage --window-size=1000,1400 --no-proxy-server --allow-file-access-from-files].freeze
    STYLES = %w[color backgroundColor paddingTop paddingRight paddingBottom paddingLeft borderTopWidth borderTopColor
                borderTopLeftRadius fontSize fontWeight lineHeight display alignItems boxShadow textAlign].freeze
    # The same font and padding on both sides, so only the component differs.
    NORMALIZE = "const s=document.createElement('style');s.textContent='*{font-family:sans-serif !important} body{padding:20px !important}';document.head.append(s);"
    ITEM = "a:not([data-dropdown-toggle]), button:not([data-dropdown-toggle])"
    DIVIDER = "hr, [role=separator]"
    NESTED = "[data-dropdown-toggle]"

    # Triggers that are not inside another dropdown's menu.
    TOP_LEVEL = <<~JS
      const toggles = [...document.querySelectorAll('[data-dropdown-toggle]')];
      const inMenu = el => {
        for (let p = el.parentElement; p; p = p.parentElement) {
          if (p.id && toggles.some(t => t !== el && t.dataset.dropdownToggle === p.id)) return true;
        }
        return false;
      };
      return toggles.filter(t => !inMenu(t));
    JS

    CAPTURE = <<~JS
      const el = arguments[0], cs = getComputedStyle(el), r = el.getBoundingClientRect();
      return {
        classes: [...el.classList],
        text: el.textContent.replace(/\\s+/g, ' ').trim(),
        tags: [...el.querySelectorAll('*')].map(e => e.tagName.toLowerCase()).filter(t => t != 'path').join(' '),
        size: [Math.round(r.width), Math.round(r.height)],
        styles: Object.fromEntries(arguments[1].map(k => [k, cs[k]]))
      };
    JS

    OFFSET = <<~JS
      const a = arguments[0].getBoundingClientRect(), b = arguments[1].getBoundingClientRect();
      return [Math.round(a.left - b.left), Math.round(a.top - b.top)];
    JS

    PIXEL_DIFF = <<~JS
      const [a, b, done] = arguments;
      const load = src => new Promise(r => { const i = new Image(); i.onload = () => r(i); i.src = 'data:image/png;base64,' + src; });
      Promise.all([load(a), load(b)]).then(([x, y]) => {
        const w = Math.min(x.width, y.width), h = Math.min(x.height, y.height);
        const read = i => { const c = document.createElement('canvas'); c.width = w; c.height = h; const g = c.getContext('2d'); g.drawImage(i, 0, 0); return g.getImageData(0, 0, w, h).data; };
        const p = read(x), q = read(y); let n = 0;
        for (let k = 0; k < p.length; k += 4) if (Math.abs(p[k]-q[k]) > 32 || Math.abs(p[k+1]-q[k+1]) > 32 || Math.abs(p[k+2]-q[k+2]) > 32) n++;
        done({ differing: n, total: w * h });
      });
    JS

    # Command line interface. Returns the process exit status.
    def run(argv, out: $stdout, err: $stderr)
      return usage(err) unless argv.size.between?(2, 3)

      page, out_dir, base = argv
      strategy = STRATEGIES.fetch(page) { raise Error, "no strategy for #{page}, add one to STRATEGIES" }
      out_dir = File.expand_path(out_dir)
      raise Error, "OUT_DIR does not exist: #{out_dir}" unless Dir.exist?(out_dir)

      blocks = compare(page, strategy, pairs(page), out_dir, base || BASE_URL)
      write_outputs(blocks, out_dir)
      out.puts summary(blocks)
      out.puts "records: #{blocks.sum { |_header, records| records.size }}"
      0
    rescue Error => e
      err.puts "flowbite-compare: #{e.message}"
      1
    end

    private

    def usage(err)
      err.puts USAGE
      1
    end

    # The manifest entries of PAGE that have a Gustwave preview to compare with.
    def pairs(page)
      entries = YAML.safe_load(File.read(MANIFEST, encoding: "utf-8")).fetch("pages").fetch(page, [])
      previewed = entries.select { |entry| entry.key?("preview") }
      raise Error, "no previewed examples for #{page} in #{MANIFEST}" if previewed.empty?

      previewed
    end

    def compare(page, strategy, pairs, out_dir, base)
      with_driver do |driver|
        THEMES.flat_map do |theme|
          pairs.map do |pair|
            meta = { "page" => page, "id" => pair["id"], "scenario" => pair["preview"].split("/").last,
                     "preview" => pair["preview"], "theme" => theme }
            compare_pair(driver, strategy, meta, out_dir, base)
          end
        end
      end
    end

    # Returns [header, records] for one example in one theme.
    def compare_pair(driver, strategy, meta, out_dir, base)
      dark = meta["theme"] == "dark"
      flowbite = captures(driver, strategy, "file://#{out_dir}/examples/#{meta["id"]}.html", dark)
      gustwave = captures(driver, strategy, preview_url(base, meta["preview"], meta["theme"]), false)
      header = "== #{meta["theme"]} #{meta["id"]} <-> #{meta["scenario"]}"
      [ header, records(driver, meta, flowbite, gustwave) ]
    end

    def preview_url(base, preview, theme)
      url = "#{base}/lookbook/preview/#{preview}"
      return url unless theme == "dark"

      "#{url}?_display=#{CGI.escape({ theme: "dark" }.to_json)}"
    end

    def with_driver
      driver = Selenium::WebDriver.for(:chrome, options: Selenium::WebDriver::Chrome::Options.new(args: CHROME_ARGS))
      driver.manage.timeouts.script_timeout = 30
      yield driver
    ensure
      driver&.quit
    end

    # One loaded side: a Hash of key => { region => capture }.
    def captures(driver, strategy, url, dark)
      case strategy
      when :static then static_captures(driver, url, dark)
      when :dropdown then dropdown_captures(driver, url, dark)
      end
    end

    # Every page load goes through here, so both sides are normalized the same way.
    def load(driver, url, dark)
      driver.navigate.to url
      sleep 1
      driver.execute_script("document.documentElement.classList.add('dark')") if dark
      driver.execute_script(NORMALIZE)
      sleep 0.3
    end

    def static_captures(driver, url, dark)
      load(driver, url, dark)
      driver.find_elements(css: "[role=alert]").each_with_index.to_h do |alert, index|
        [ index.to_s, { "alert" => capture(driver, alert) } ]
      end
    end

    def dropdown_captures(driver, url, dark)
      load(driver, url, dark)
      triggers = top_level_triggers(driver)
      dropdown_keys(driver, triggers).each_with_index.to_h do |key, index|
        [ key, dropdown_regions(driver, url, dark, index) ]
      end
    end

    def top_level_triggers(driver)
      driver.execute_script(TOP_LEVEL).select(&:displayed?)
    end

    # The placement when it is unique on the page, otherwise the position.
    def dropdown_keys(driver, triggers)
      placements = driver.find_elements(css: "[data-dropdown-placement]").map { |el| el.attribute("data-dropdown-placement") }
      triggers.each_with_index.map do |trigger, index|
        placement = trigger.attribute("data-dropdown-placement")
        placement && placements.count(placement) == 1 ? placement : index.to_s
      end
    end

    # Reloads the page, so each trigger starts from a clean state.
    def dropdown_regions(driver, url, dark, index)
      load(driver, url, dark)
      driver.execute_script("document.body.click()")
      sleep 0.3
      trigger = top_level_triggers(driver)[index]
      return { "trigger" => { "error" => "trigger not found after reload" } } unless trigger

      open_trigger(driver, trigger)
      regions = { "trigger" => capture(driver, trigger) }
      menu = menu_of(driver, trigger)
      if menu&.displayed?
        regions.merge!(open_menu_regions(driver, trigger, menu))
      else
        regions["trigger"]["menu_open"] = false
      end
      regions
    rescue Selenium::WebDriver::Error::WebDriverError => e
      { "trigger" => { "error" => e.message } }
    end

    def open_menu_regions(driver, trigger, menu)
      nested = menu.find_elements(css: NESTED).first
      regions = {
        "menu" => capture(driver, menu).merge("offset" => offset(driver, menu, trigger)),
        "item" => first_capture(driver, menu, ITEM),
        "divider" => first_capture(driver, menu, DIVIDER),
        "nested" => nested && capture(driver, nested)
      }.compact
      nested ? regions.merge(submenu_regions(driver, nested)) : regions
    end

    def submenu_regions(driver, nested)
      open_trigger(driver, nested)
      submenu = menu_of(driver, nested)
      return {} unless submenu&.displayed?

      { "submenu" => capture(driver, submenu).merge("offset" => offset(driver, submenu, nested)) }
    end

    def first_capture(driver, root, css)
      element = root.find_elements(css:).first
      element && capture(driver, element)
    end

    def open_trigger(driver, trigger)
      if trigger.attribute("data-dropdown-trigger") == "hover"
        driver.action.move_to(trigger).perform
      else
        trigger.click
      end
      sleep 0.5
    end

    def menu_of(driver, trigger)
      driver.execute_script("return document.getElementById(arguments[0])", trigger.attribute("data-dropdown-toggle"))
    end

    def offset(driver, element, anchor)
      driver.execute_script(OFFSET, element, anchor)
    end

    # Element screenshot failures are recorded on the capture, not raised.
    def capture(driver, element)
      data = driver.execute_script(CAPTURE, element, STYLES)
      data["png"] = element.screenshot_as(:base64)
      data
    rescue Selenium::WebDriver::Error::WebDriverError => e
      (data || {}).merge("error" => e.message)
    end

    def records(driver, meta, flowbite, gustwave)
      (flowbite.keys | gustwave.keys).flat_map do |key|
        fb = flowbite.fetch(key, {})
        gw = gustwave.fetch(key, {})
        (fb.keys | gw.keys).map do |region|
          record(driver, meta, { "key" => key, "region" => region }, fb[region], gw[region])
        end
      end
    end

    def record(driver, meta, place, flowbite, gustwave)
      fields = {
        "missing" => missing(flowbite, gustwave),
        "menu_open" => menu_open(flowbite, gustwave),
        "pct" => pct(driver, flowbite&.dig("png"), gustwave&.dig("png")),
        "error" => errors(flowbite, gustwave),
        "fb_png" => flowbite&.dig("png"),
        "gw_png" => gustwave&.dig("png")
      }
      meta.merge(place).merge(fields).merge(side_fields(place["region"], flowbite, gustwave)).compact
    end

    # What each side reports on its own, plus the comparison when both exist.
    def side_fields(region, flowbite, gustwave)
      fields = {
        "fb_size" => flowbite&.dig("size"), "gw_size" => gustwave&.dig("size"),
        "fb_offset" => flowbite&.dig("offset"), "gw_offset" => gustwave&.dig("offset"),
        "fb_text" => flowbite&.dig("text"), "gw_text" => gustwave&.dig("text"),
        "fb_tags" => flowbite&.dig("tags"), "gw_tags" => gustwave&.dig("tags")
      }
      return fields unless flowbite && gustwave

      fields.merge(
        "style_diffs" => style_diffs(region, flowbite, gustwave),
        "classes_only_flowbite" => flowbite["classes"] - gustwave["classes"],
        "classes_only_gustwave" => gustwave["classes"] - flowbite["classes"]
      )
    end

    def missing(flowbite, gustwave)
      return "flowbite" unless flowbite

      "gustwave" unless gustwave
    end

    def menu_open(flowbite, gustwave)
      states = [ flowbite, gustwave ].compact.map { |capture| capture["menu_open"] }
      false if states.include?(false)
    end

    def errors(flowbite, gustwave)
      messages = [ flowbite, gustwave ].compact.filter_map { |capture| capture["error"] }
      messages.join("; ") if messages.any?
    end

    def pct(driver, before, after)
      return unless before && after

      result = pixel_diff(driver, before, after)
      return if result["total"].zero?

      (100.0 * result["differing"] / result["total"]).round(2)
    end

    def pixel_diff(driver, before, after)
      driver.navigate.to "about:blank"
      driver.execute_async_script(PIXEL_DIFF, before, after)
    end

    def style_diffs(region, flowbite, gustwave)
      names = STYLES.dup
      names -= [ "borderTopColor" ] if flowbite["styles"]["borderTopWidth"] == "0px" && gustwave["styles"]["borderTopWidth"] == "0px"
      names -= %w[fontSize lineHeight color] if region == "alert"
      names.filter_map do |name|
        before, after = flowbite["styles"][name], gustwave["styles"][name]
        "#{name}: #{before} -> #{after}" if before != after
      end
    end

    def write_outputs(blocks, out_dir)
      records = blocks.flat_map(&:last)
      File.write(File.join(out_dir, "results.json"), JSON.pretty_generate(records), encoding: "utf-8")
      File.write(File.join(out_dir, "summary.txt"), "#{summary(blocks)}\n", encoding: "utf-8")
      File.write(File.join(out_dir, "report.html"), report(blocks), encoding: "utf-8")
    end

    def summary(blocks)
      blocks.map do |header, records|
        [ header, *records.flat_map { |record| summary_lines(record) } ].join("\n")
      end.join("\n\n")
    end

    def summary_lines(record)
      [ "  #{caption(record)}".rstrip, *details(record).map { |line| "    #{line}" } ]
    end

    def caption(record)
      parts = []
      parts << "size #{dims(record["fb_size"])} vs #{dims(record["gw_size"])}" if record["fb_size"] || record["gw_size"]
      parts << "offset #{offset_text(record["fb_offset"])} vs #{offset_text(record["gw_offset"])}" if record["fb_offset"] || record["gw_offset"]
      parts << "pixels differ #{record["pct"]}%" if record["pct"]
      "#{record["key"]} #{record["region"]}: #{parts.join(", ")}"
    end

    def dims(size)
      size ? size.join("x") : "-"
    end

    def offset_text(offset)
      offset ? offset.join(",") : "-"
    end

    def details(record)
      lines = []
      lines << "missing: #{record["missing"]}" if record["missing"]
      lines << "menu_open: false" if record["menu_open"] == false
      lines << "error: #{record["error"]}" if record["error"]
      if differing?(record, "text")
        lines << "text differs: \"#{record["fb_text"][0, 70]}\" | \"#{record["gw_text"][0, 70]}\""
      end
      lines << "tags differ: #{record["fb_tags"]} | #{record["gw_tags"]}" if differing?(record, "tags")
      lines << "classes only flowbite: #{record["classes_only_flowbite"].join(" ")}" if record["classes_only_flowbite"]&.any?
      lines << "classes only gustwave: #{record["classes_only_gustwave"].join(" ")}" if record["classes_only_gustwave"]&.any?
      lines << "computed: #{record["style_diffs"].join("; ")}" if record["style_diffs"]&.any?
      lines
    end

    def differing?(record, name)
      fb, gw = record["fb_#{name}"], record["gw_#{name}"]
      !fb.nil? && !gw.nil? && fb != gw
    end

    def report(blocks)
      sections = blocks.map do |header, records|
        "<h2>#{CGI.escapeHTML(header)}</h2>\n#{records.map { |record| report_record(record) }.join}"
      end
      <<~HTML
        <!DOCTYPE html>
        <html lang="en">
        <meta charset="utf-8">
        <title>Flowbite and Gustwave comparison</title>
        <body style="font: 14px sans-serif; margin: 16px">
        #{sections.join}
        </body>
        </html>
      HTML
    end

    def report_record(record)
      "<div style=\"margin: 8px 0\"><p>#{CGI.escapeHTML(caption(record))}</p>" \
        "#{report_image("Flowbite", record["fb_png"])}#{report_image("Gustwave", record["gw_png"])}</div>\n"
    end

    def report_image(label, png)
      return "<p>#{label}: no image</p>" unless png

      "<p>#{label}</p><img src=\"data:image/png;base64,#{png}\" style=\"max-width: 900px; display: block\">"
    end
  end
end

exit(Gustwave::FlowbiteCompare.run(ARGV)) if __FILE__ == $PROGRAM_NAME
