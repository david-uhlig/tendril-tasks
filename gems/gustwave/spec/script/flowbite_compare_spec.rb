# frozen_string_literal: true

require "spec_helper"
require_relative "../../script/flowbite_compare"

RSpec.describe Gustwave::FlowbiteCompare do
  describe ".review_reasons" do
    def reasons(record) = described_class.review_reasons(record)

    it "returns no reasons for a clean record" do
      record = { "fb_size" => [ 165, 40 ], "gw_size" => [ 165, 40 ], "pct" => 0.0 }

      expect(reasons(record)).to eq([])
    end

    it "flags a record only on gustwave" do
      expect(reasons({ "missing" => "flowbite" })).to eq([ "only on gustwave" ])
    end

    it "flags a record only on flowbite" do
      expect(reasons({ "missing" => "gustwave" })).to eq([ "only on flowbite" ])
    end

    it "flags an error" do
      expect(reasons({ "error" => "stale element" })).to eq([ "error" ])
    end

    it "flags a menu that did not open" do
      expect(reasons({ "menu_open" => false })).to eq([ "menu did not open" ])
    end

    it "does not flag an open menu" do
      expect(reasons({ "menu_open" => true })).to eq([])
    end

    it "flags text nodes that differ in count" do
      expect(reasons({ "text_nodes" => [ 4, 2 ] })).to eq([ "text nodes 4 vs 2" ])
    end

    it "does not flag text nodes that match" do
      expect(reasons({ "text_nodes" => [ 2, 2 ] })).to eq([])
    end

    it "does not flag a size exactly at the tolerance" do
      record = { "fb_size" => [ 165, 40 ], "gw_size" => [ 167, 38 ] }

      expect(reasons(record)).to eq([])
    end

    it "flags a size over the tolerance" do
      record = { "fb_size" => [ 165, 40 ], "gw_size" => [ 169, 40 ] }

      expect(reasons(record)).to eq([ "size 165x40 vs 169x40" ])
    end

    it "does not flag an offset exactly at the tolerance" do
      record = { "fb_offset" => [ 186, 0 ], "gw_offset" => [ 184, 2 ] }

      expect(reasons(record)).to eq([])
    end

    it "flags an offset over the tolerance" do
      record = { "fb_offset" => [ 186, 0 ], "gw_offset" => [ 116, -24 ] }

      expect(reasons(record)).to eq([ "offset 186,0 vs 116,-24" ])
    end

    it "does not flag a pixel share below the flag" do
      expect(reasons({ "pct" => 0.99 })).to eq([])
    end

    it "flags a pixel share at the flag" do
      expect(reasons({ "pct" => 1.0 })).to eq([ "pixels 1.0%" ])
    end

    def icon(ink: [ 2, 2, 12, 12 ], paints: [ "rgb(1, 2, 3)" ])
      { "box" => [ 0, 0, 16, 16 ], "ink" => ink, "paints" => paints }
    end

    def icon_reasons(flowbite, gustwave) = reasons({ "fb_icons" => [ flowbite ], "gw_icons" => [ gustwave ] })

    it "does not flag icons that match" do
      expect(icon_reasons(icon, icon)).to eq([])
    end

    it "does not flag a different svg box around the same drawing" do
      gustwave = icon.merge("box" => [ 0, 0, 24, 24 ])

      expect(icon_reasons(icon, gustwave)).to eq([])
    end

    it "flags a different number of icons" do
      expect(reasons({ "fb_icons" => [ icon ], "gw_icons" => [] })).to eq([ "icons 1 vs 0" ])
    end

    it "does not flag a drawing size exactly at the tolerance" do
      expect(icon_reasons(icon(ink: [ 2, 2, 12, 12 ]), icon(ink: [ 3, 3, 10, 10 ]))).to eq([])
    end

    it "flags a drawing size over the tolerance" do
      expect(icon_reasons(icon(ink: [ 2, 2, 12, 12 ]), icon(ink: [ 0.5, 2, 15, 12 ]))).to eq([ "icon 1 size 12x12 vs 15x12" ])
    end

    it "does not flag a centre exactly at the tolerance" do
      expect(icon_reasons(icon(ink: [ 2, 2, 12, 12 ]), icon(ink: [ 3, 2, 12, 12 ]))).to eq([])
    end

    it "flags a centre over the tolerance" do
      expect(icon_reasons(icon(ink: [ 2, 2, 12, 12 ]), icon(ink: [ 4, 2, 12, 12 ]))).to eq([ "icon 1 centre 8.0,8.0 vs 10.0,8.0" ])
    end

    it "flags icons with no colour in common" do
      flowbite, gustwave = icon(paints: [ "rgb(1, 2, 3)" ]), icon(paints: [ "rgb(4, 5, 6)" ])

      expect(icon_reasons(flowbite, gustwave)).to eq([ "icon 1 colour rgb(1, 2, 3) vs rgb(4, 5, 6)" ])
    end

    it "does not flag artwork that adds a detail colour" do
      flowbite, gustwave = icon(paints: [ "rgb(1, 2, 3)", "rgb(255, 255, 255)" ]), icon(paints: [ "rgb(1, 2, 3)" ])

      expect(icon_reasons(flowbite, gustwave)).to eq([])
    end

    it "ignores icons when a side was not captured" do
      expect(reasons({ "fb_icons" => [ icon ] })).to eq([])
    end
  end

  describe ".mask_boxes" do
    it "covers every icon from both sides, one pixel further" do
      flowbite = [ { "box" => [ 2, 3, 12, 14 ] } ]
      gustwave = [ { "box" => [ 4, 5, 10, 10 ] } ]

      expect(described_class.mask_boxes(flowbite, gustwave)).to eq([ [ 1, 2, 14, 16 ], [ 3, 4, 12, 12 ] ])
    end

    it "covers nothing without icons" do
      expect(described_class.mask_boxes(nil, [])).to eq([])
    end
  end

  describe ".look_at?" do
    it "asks for a look when icon pixels differ" do
      expect(described_class.look_at?({ "icon_pct" => 0.5 })).to be(true)
    end

    it "does not ask when icon pixels match" do
      expect(described_class.look_at?({ "icon_pct" => 0.0 })).to be(false)
    end

    it "does not ask without icons" do
      expect(described_class.look_at?({})).to be(false)
    end
  end

  describe ".strategy_for_pair" do
    def strategy_for_pair(pair, page_strategy) = described_class.send(:strategy_for_pair, pair, page_strategy)

    it "gives a listed example its own strategy" do
      expect(strategy_for_pair({ "id" => "avatar-user-dropdown-example" }, :static)).to eq(:dropdown)
      expect(strategy_for_pair({ "id" => "card-user-profile-example" }, :static)).to eq(:dropdown)
    end

    it "gives any other example the page strategy" do
      expect(strategy_for_pair({ "id" => "avatar-sizes-example" }, :static)).to eq(:static)
    end
  end

  describe ".strategy_for" do
    def strategy_for(page) = described_class.send(:strategy_for, page)

    it "opens the modals of the modal page" do
      expect(strategy_for("components/modal")).to eq(:modal)
    end

    it "opens the dropdowns of the navbar page" do
      expect(strategy_for("components/navbar")).to eq(:navbar)
    end

    it "refuses a page whose interactions no strategy covers" do
      expect { strategy_for("components/drawer") }.to raise_error(described_class::Error, /interaction strategy/)
    end
  end

  describe ".unwrap" do
    def unwrap(elements, wanted) = described_class.send(:unwrap, nil, elements, wanted)

    def element(tag, children: [], displayed: true)
      double("element #{tag}", tag_name: tag, find_elements: children, displayed?: displayed)
    end

    def reference(*tags) = tags.each_with_index.to_h { |tag, index| [ index.to_s, { "element" => { "tag" => tag } } ] }

    it "steps into a lone div when the reference's one element is not a div" do
      child = element("a")
      wrapper = element("div", children: [ child ])

      expect(unwrap([ wrapper ], reference("a"))).to eq([ child ])
    end

    it "keeps a lone div when the reference's one element is a div" do
      wrapper = element("div", children: [ element("a") ])

      expect(unwrap([ wrapper ], reference("div"))).to eq([ wrapper ])
    end

    it "steps into a lone div when the reference has several elements" do
      link, paragraph = element("a"), element("p")
      wrapper = element("div", children: [ link, paragraph ])

      expect(unwrap([ wrapper ], reference("div", "p"))).to eq([ link, paragraph ])
    end

    it "keeps a lone element that is not a div when the reference's one element is not a div" do
      link = element("a", children: [ element("span") ])

      expect(unwrap([ link ], reference("p"))).to eq([ link ])
    end

    it "keeps a lone div without displayed children" do
      wrapper = element("div", children: [ element("a", displayed: false) ])

      expect(unwrap([ wrapper ], reference("a"))).to eq([ wrapper ])
    end
  end

  describe ".dropdown_keys" do
    def trigger(placement) = double("trigger", attribute: placement)
    def dropdown_keys(*triggers) = described_class.send(:dropdown_keys, nil, triggers)

    it "keys a lone explicit bottom placement by position" do
      expect(dropdown_keys(trigger("bottom"))).to eq([ "0" ])
    end

    it "keys a missing placement by position" do
      expect(dropdown_keys(trigger(nil))).to eq([ "0" ])
    end

    it "keys a missing placement as bottom beside other placements" do
      expect(dropdown_keys(trigger("top"), trigger(nil))).to eq([ "top", "bottom" ])
    end
  end

  describe "the reminder in the output" do
    let(:differing) { { "key" => "0", "region" => "element", "pct" => 0.0, "icon_pct" => 12.5, "review" => [] } }
    let(:matching) { { "key" => "1", "region" => "element", "pct" => 0.0, "icon_pct" => 0.0, "review" => [] } }
    let(:flagged) { { "key" => "2", "region" => "element", "pct" => 3.0, "icon_pct" => 1.0, "review" => [ "pixels 3.0%" ] } }

    def summary(*records) = described_class.send(:summary, [ [ "== header", records ] ])
    def report(*records) = described_class.send(:report, [ [ "== header", records ] ])

    it "tags and explains an element with differing icon pixels" do
      expect(summary(differing)).to include(
        "[look] 0 element: pixels differ 0.0%, icon pixels differ 12.5%",
        "look by eye: a wrong icon or line thickness raises no flag"
      )
    end

    it "stays quiet about icons whose pixels match" do
      output = summary(matching)

      expect(output).to include("[ok] 1 element")
      expect(output).not_to include("look by eye:")
    end

    it "keeps the reminder on a flagged element" do
      expect(summary(flagged)).to include("[review] 2 element", "look by eye:")
    end

    it "counts the elements to look at" do
      expect(summary(differing, matching, flagged)).to include(
        "records: 3, to review: 1",
        "icons to look at by eye: 2 (a wrong icon or line thickness raises no flag)"
      )
    end

    it "reports none without the explanation" do
      expect(summary(matching)).to end_with("icons to look at by eye: 0")
    end

    it "repeats the reminder in the report" do
      expect(report(differing)).to include(
        "<p>icons to look at by eye: 1 (a wrong icon or line thickness raises no flag)</p>",
        "<p>Look by eye: a wrong icon or line thickness raises no flag</p>"
      )
    end
  end
end
