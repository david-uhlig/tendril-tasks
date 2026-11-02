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

    it "does not flag icons that match" do
      icon = { "box" => [ 2, 2, 12, 12 ], "paints" => [ "rgb(1, 2, 3)" ] }

      expect(reasons({ "fb_icons" => [ icon ], "gw_icons" => [ icon ] })).to eq([])
    end

    it "does not flag icon boxes exactly at the tolerance" do
      fb = { "box" => [ 2, 2, 12, 12 ], "paints" => [ "rgb(1, 2, 3)" ] }
      gw = { "box" => [ 3, 3, 13, 13 ], "paints" => [ "rgb(1, 2, 3)" ] }

      expect(reasons({ "fb_icons" => [ fb ], "gw_icons" => [ gw ] })).to eq([])
    end

    it "flags a different number of icons" do
      fb = { "box" => [ 2, 2, 12, 12 ], "paints" => [ "rgb(1, 2, 3)" ] }

      expect(reasons({ "fb_icons" => [ fb ], "gw_icons" => [] })).to eq([ "icons 1 vs 0" ])
    end

    it "flags an icon size over the tolerance" do
      fb = { "box" => [ 2, 2, 12, 12 ], "paints" => [ "rgb(1, 2, 3)" ] }
      gw = { "box" => [ 2, 2, 14, 12 ], "paints" => [ "rgb(1, 2, 3)" ] }

      expect(reasons({ "fb_icons" => [ fb ], "gw_icons" => [ gw ] })).to eq([ "icon 1 size 12x12 vs 14x12" ])
    end

    it "flags an icon position over the tolerance" do
      fb = { "box" => [ 2, 2, 12, 12 ], "paints" => [ "rgb(1, 2, 3)" ] }
      gw = { "box" => [ 4, 2, 12, 12 ], "paints" => [ "rgb(1, 2, 3)" ] }

      expect(reasons({ "fb_icons" => [ fb ], "gw_icons" => [ gw ] })).to eq([ "icon 1 position 2,2 vs 4,2" ])
    end

    it "flags an icon colour" do
      fb = { "box" => [ 2, 2, 12, 12 ], "paints" => [ "rgb(1, 2, 3)" ] }
      gw = { "box" => [ 2, 2, 12, 12 ], "paints" => [ "rgb(4, 5, 6)" ] }

      expect(reasons({ "fb_icons" => [ fb ], "gw_icons" => [ gw ] })).to eq([ "icon 1 colour rgb(1, 2, 3) vs rgb(4, 5, 6)" ])
    end

    it "ignores icons when a side was not captured" do
      fb = { "box" => [ 2, 2, 12, 12 ], "paints" => [ "rgb(1, 2, 3)" ] }

      expect(reasons({ "fb_icons" => [ fb ] })).to eq([])
    end
  end
end
