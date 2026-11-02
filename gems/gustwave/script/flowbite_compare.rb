# frozen_string_literal: true

require "cgi"
require "json"
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
    STRATEGIES = { "components/dropdowns" => :dropdown }.freeze
    # Pages whose interactions no strategy covers yet. Each needs one before it runs.
    NOT_YET = %w[speed-dial drawer tabs navbar tooltips modal popover].map { "components/#{_1}" }.freeze
    SIZE_TOLERANCE = 2
    # Only sorts what a person looks at and decides nothing. The 1.0 value comes from
    # two components so far.
    PIXEL_FLAG = 1.0
    USAGE = "Usage: bundle exec ruby gems/gustwave/script/flowbite_compare.rb PAGE OUT_DIR [BASE_URL]"
    CHROME_ARGS = %w[--headless=new --no-sandbox --disable-dev-shm-usage --window-size=1000,1400 --no-proxy-server --allow-file-access-from-files].freeze
    STYLES = %w[color backgroundColor paddingTop paddingRight paddingBottom paddingLeft borderTopWidth borderTopColor
                borderTopLeftRadius fontSize fontWeight lineHeight display alignItems boxShadow textAlign].freeze
    # The same font and padding on both sides, so only the component differs.
    NORMALIZE = "const s=document.createElement('style');s.textContent='*{font-family:sans-serif !important} body{padding:20px !important}';document.head.append(s);"
    # The wrapper's children on a Flowbite page, the body's children on a preview.
    ELEMENTS = "#exampleWrapper > *, body > *:not(#exampleWrapper):not(script):not(style):not(link):not(noscript)"
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

    # Visible text nodes, so the comparison can use Flowbite's exact text on both sides.
    FB_VISIBLE_TEXT = <<~JS
      window.fbVisibleText = root => {
        const walker = document.createTreeWalker(root, NodeFilter.SHOW_TEXT), out = [];
        while (walker.nextNode()) {
          const n = walker.currentNode;
          if (n.textContent.trim() && !n.parentElement.closest('.sr-only')) out.push(n);
        }
        return out;
      };
    JS

    CAPTURE = <<~JS
      const el = arguments[0], cs = getComputedStyle(el), r = el.getBoundingClientRect();
      return {
        classes: [...el.classList],
        text: el.textContent.replace(/\\s+/g, ' ').trim(),
        text_parts: fbVisibleText(el).map(n => n.textContent.replace(/\\s+/g, ' ')),
        tags: [...el.querySelectorAll('*')].map(e => e.tagName.toLowerCase()).filter(t => t != 'path').join(' '),
        size: [Math.round(r.width), Math.round(r.height)],
        styles: Object.fromEntries(arguments[1].map(k => [k, cs[k]]))
      };
    JS

    # Sets the text nodes of an element to the reference values, if the counts match.
    SWAP_TEXT = <<~JS
      const [el, values] = arguments;
      const nodes = fbVisibleText(el);
      const original = nodes.map(n => n.textContent).join('').trim();
      if (nodes.length !== values.length) return { swapped: false, original_text: original, own_parts: nodes.length };
      nodes.forEach((n, i) => { n.textContent = values[i]; });
      return { swapped: true, original_text: original, own_parts: nodes.length };
    JS

    # Text renders differently at a fractional position, for example when Flowbite
    # centers an example, so both sides move to a whole pixel before a screenshot.
    SNAP = <<~JS
      const el = arguments[0], left = el.getBoundingClientRect().left;
      if (left !== Math.round(left) && getComputedStyle(el).position === 'static') {
        el.style.position = 'relative';
        el.style.left = (Math.round(left) - left) + 'px';
      }
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
      strategy = strategy_for(page)
      out_dir = File.expand_path(out_dir)
      raise Error, "OUT_DIR does not exist: #{out_dir}" unless Dir.exist?(out_dir)

      blocks = compare(page, strategy, pairs(page), out_dir, base || BASE_URL)
      write_outputs(blocks, out_dir)
      out.puts summary(blocks)
      0
    rescue Error => e
      err.puts "flowbite-compare: #{e.message}"
      1
    end

    # Flagged for a person to look at; nothing here decides a verdict.
    def review_reasons(record)
      reasons = []
      reasons << "only on gustwave" if record["missing"] == "flowbite"
      reasons << "only on flowbite" if record["missing"] == "gustwave"
      reasons << "error" if record["error"]
      reasons << "menu did not open" if record["menu_open"] == false
      if record["text_nodes"]
        flowbite_count, gustwave_count = record["text_nodes"]
        reasons << "text nodes #{flowbite_count} vs #{gustwave_count}" if flowbite_count != gustwave_count
      end
      fb_size, gw_size = record["fb_size"], record["gw_size"]
      if fb_size && gw_size && beyond?(fb_size, gw_size, SIZE_TOLERANCE)
        reasons << "size #{dims(fb_size)} vs #{dims(gw_size)}"
      end
      fb_offset, gw_offset = record["fb_offset"], record["gw_offset"]
      if fb_offset && gw_offset && beyond?(fb_offset, gw_offset, SIZE_TOLERANCE)
        reasons << "offset #{offset_text(fb_offset)} vs #{offset_text(gw_offset)}"
      end
      reasons << "pixels #{record["pct"]}%" if record["pct"] && record["pct"] >= PIXEL_FLAG
      reasons
    end

    private

    def usage(err)
      err.puts USAGE
      1
    end

    def strategy_for(page)
      raise Error, "#{page} needs an interaction strategy first" if NOT_YET.include?(page)

      STRATEGIES.fetch(page, :static)
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
    # Flowbite goes first: its text is the reference the Gustwave preview takes on.
    def compare_pair(driver, strategy, meta, out_dir, base)
      dark = meta["theme"] == "dark"
      flowbite = captures(driver, strategy, "file://#{out_dir}/examples/#{meta["id"]}.html", dark)
      gustwave = captures(driver, strategy, preview_url(base, meta["preview"], meta["theme"]), false, reference: flowbite)
      header = "== #{meta["theme"]} #{meta["id"]} <-> #{meta["scenario"]}"
      [ header, records(driver, meta, flowbite, gustwave) ]
    end

    def preview_url(base, preview, theme)
      url = "#{base}/lookbook/preview/#{preview}"
      return url unless theme == "dark"

      "#{url}?_display=#{CGI.escape({ theme: "dark" }.to_json)}"
    end

    def with_driver
      require "selenium-webdriver"

      driver = Selenium::WebDriver.for(:chrome, options: Selenium::WebDriver::Chrome::Options.new(args: CHROME_ARGS))
      driver.manage.timeouts.script_timeout = 30
      yield driver
    ensure
      driver&.quit
    end

    # One loaded side: a Hash of key => { region => capture }.
    # With a reference (Flowbite's captures), the Gustwave side takes on its text.
    def captures(driver, strategy, url, dark, reference: nil)
      case strategy
      when :static then static_captures(driver, url, dark, reference:)
      when :dropdown then dropdown_captures(driver, url, dark, reference:)
      end
    end

    # Every page load goes through here, so both sides are normalized the same way.
    def load(driver, url, dark)
      driver.navigate.to url
      sleep 1
      driver.execute_script(FB_VISIBLE_TEXT)
      driver.execute_script("document.documentElement.classList.add('dark')") if dark
      driver.execute_script(NORMALIZE)
      sleep 0.3
    end

    def static_captures(driver, url, dark, reference: nil)
      load(driver, url, dark)
      elements = visible_elements(driver)
      # Previews often wrap what a Flowbite example has at the top level.
      elements = unwrap(driver, elements, reference) if reference
      elements.each_with_index.to_h do |element, index|
        key = index.to_s
        swap = swap_text(driver, element, reference&.dig(key, "element"))
        [ key, { "element" => capture(driver, element).merge(swap) } ]
      end
    end

    def visible_elements(driver)
      driver.find_elements(css: ELEMENTS).select(&:displayed?)
    end

    # Replaces a lone wrapper with its displayed children while the reference has several elements.
    # Only a div counts as a wrapper: stepping into a lone badge or button would compare its icon with
    # the reference's whole element. An element without displayed element children stays as it is.
    def unwrap(driver, elements, wanted)
      while elements.size == 1 && wanted.size > 1 && elements.first.tag_name == "div"
        children = elements.first.find_elements(xpath: "./*").select(&:displayed?)
        break if children.empty?

        elements = children
      end
      elements
    end

    def dropdown_captures(driver, url, dark, reference: nil)
      load(driver, url, dark)
      triggers = top_level_triggers(driver)
      dropdown_keys(driver, triggers).each_with_index.to_h do |key, index|
        [ key, dropdown_regions(driver, url, dark, index, key:, reference:) ]
      end
    end

    def top_level_triggers(driver)
      driver.execute_script(TOP_LEVEL).select(&:displayed?)
    end

    # The placement when it is unique among the triggers, otherwise the position.
    # A missing attribute means bottom, Flowbite's default placement.
    def dropdown_keys(driver, triggers)
      placements = triggers.map { |trigger| trigger.attribute("data-dropdown-placement") }
      return triggers.each_index.map(&:to_s) if placements.compact.empty?

      placements = placements.map { |placement| placement || "bottom" }
      placements.each_with_index.map do |placement, index|
        placements.count(placement) == 1 ? placement : index.to_s
      end
    end

    # Reloads the page, so each trigger starts from a clean state.
    # The text is swapped before opening, so the positioning library measures the final sizes.
    def dropdown_regions(driver, url, dark, index, key:, reference:)
      load(driver, url, dark)
      driver.execute_script("document.body.click()")
      sleep 0.3
      trigger = top_level_triggers(driver)[index]
      return { "trigger" => { "error" => "trigger not found after reload" } } unless trigger

      trigger_swap = swap_text(driver, trigger, reference&.dig(key, "trigger"))
      menu = menu_of(driver, trigger)
      menu_swap = menu ? swap_text(driver, menu, reference&.dig(key, "menu")) : {}
      open_trigger(driver, trigger)
      regions = { "trigger" => capture(driver, trigger).merge(trigger_swap) }
      if menu&.displayed?
        regions.merge!(open_menu_regions(driver, trigger, menu, menu_swap))
      else
        regions["trigger"]["menu_open"] = false
      end
      regions
    rescue Selenium::WebDriver::Error::WebDriverError => e
      { "trigger" => { "error" => e.message } }
    end

    def open_menu_regions(driver, trigger, menu, menu_swap)
      nested = menu.find_elements(css: NESTED).first
      shared = menu_swap.slice("swapped")
      regions = {
        "menu" => capture(driver, menu).merge(menu_swap).merge("offset" => offset(driver, menu, trigger)),
        "item" => first_capture(driver, menu, ITEM)&.merge(shared),
        "divider" => first_capture(driver, menu, DIVIDER)&.merge(shared),
        "nested" => nested && capture(driver, nested).merge(shared)
      }.compact
      nested ? regions.merge(submenu_regions(driver, nested, shared)) : regions
    end

    def submenu_regions(driver, nested, shared)
      open_trigger(driver, nested)
      submenu = menu_of(driver, nested)
      return {} unless submenu&.displayed?

      { "submenu" => capture(driver, submenu).merge(shared).merge("offset" => offset(driver, submenu, nested)) }
    end

    # Sets the element's own text to the reference text. Returns {} without a reference.
    def swap_text(driver, element, reference_capture)
      values = reference_capture&.dig("text_parts")
      return {} unless values

      result = driver.execute_script(SWAP_TEXT, element, values)
      sleep 0.2 if result["swapped"]
      result
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
      driver.execute_script(SNAP, element)
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

    def beyond?(before, after, tolerance)
      before.zip(after).any? { |a, b| (a - b).abs > tolerance }
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
      built = meta.merge(place).merge(fields).merge(side_fields(flowbite, gustwave)).merge(text_fields(flowbite, gustwave)).compact
      built.merge("review" => review_reasons(built))
    end

    # The text the Gustwave side ended with, and how many text nodes each side has.
    def text_fields(flowbite, gustwave)
      fields = { "swapped" => gustwave&.dig("swapped"), "gw_original_text" => gustwave&.dig("original_text") }
      flowbite_parts, gustwave_parts = flowbite&.dig("text_parts"), gustwave&.dig("own_parts")
      fields["text_nodes"] = [ flowbite_parts.size, gustwave_parts ] if flowbite_parts && gustwave_parts
      fields
    end

    # What each side reports on its own, plus the comparison when both exist.
    def side_fields(flowbite, gustwave)
      fields = {
        "fb_size" => flowbite&.dig("size"), "gw_size" => gustwave&.dig("size"),
        "fb_offset" => flowbite&.dig("offset"), "gw_offset" => gustwave&.dig("offset"),
        "fb_text" => flowbite&.dig("text"), "gw_text" => gustwave&.dig("text"),
        "fb_tags" => flowbite&.dig("tags"), "gw_tags" => gustwave&.dig("tags")
      }
      return fields unless flowbite && gustwave

      fields.merge(
        "style_diffs" => style_diffs(flowbite, gustwave),
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

    def style_diffs(flowbite, gustwave)
      names = STYLES.dup
      names -= [ "borderTopColor" ] if flowbite["styles"]["borderTopWidth"] == "0px" && gustwave["styles"]["borderTopWidth"] == "0px"
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
      body = blocks.map do |header, records|
        [ header, *records.flat_map { |record| summary_lines(record) } ].join("\n")
      end.join("\n\n")
      records = blocks.flat_map(&:last)
      flagged = records.count { |record| flagged?(record) }
      "#{body}\n\nrecords: #{records.size}, to review: #{flagged}"
    end

    def flagged?(record)
      record["review"]&.any? || false
    end

    def review_tag(record)
      flagged?(record) ? "[review]" : "[ok]"
    end

    def summary_lines(record)
      [ "  #{caption(record)}".rstrip, *details(record).map { |line| "    #{line}" } ]
    end

    def caption(record)
      parts = []
      parts << "size #{dims(record["fb_size"])} vs #{dims(record["gw_size"])}" if record["fb_size"] || record["gw_size"]
      parts << "offset #{offset_text(record["fb_offset"])} vs #{offset_text(record["gw_offset"])}" if record["fb_offset"] || record["gw_offset"]
      parts << "pixels differ #{record["pct"]}%" if record["pct"]
      "#{review_tag(record)} #{record["key"]} #{record["region"]}: #{parts.join(", ")}"
    end

    def dims(size)
      size ? size.join("x") : "-"
    end

    def offset_text(offset)
      offset ? offset.join(",") : "-"
    end

    def details(record)
      lines = []
      lines << "review: #{record["review"].join("; ")}" if flagged?(record)
      lines << "missing: #{record["missing"]}" if record["missing"]
      lines << "menu_open: false" if record["menu_open"] == false
      lines << "error: #{record["error"]}" if record["error"]
      if record["swapped"] != true && differing?(record, "text")
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
      notes = []
      notes << "<p>review: #{CGI.escapeHTML(record["review"].join("; "))}</p>" if flagged?(record)
      notes << "<p>Preview text: #{CGI.escapeHTML(record["gw_original_text"])}</p>" if record["swapped"] == true && record["gw_original_text"]
      "<div style=\"margin: 8px 0\"><p>#{CGI.escapeHTML(caption(record))}</p>#{notes.join}" \
        "#{report_image("Flowbite", record["fb_png"])}#{report_image("Gustwave", record["gw_png"])}</div>\n"
    end

    def report_image(label, png)
      return "<p>#{label}: no image</p>" unless png

      "<p>#{label}</p><img src=\"data:image/png;base64,#{png}\" style=\"max-width: 900px; display: block\">"
    end
  end
end

exit(Gustwave::FlowbiteCompare.run(ARGV)) if __FILE__ == $PROGRAM_NAME
