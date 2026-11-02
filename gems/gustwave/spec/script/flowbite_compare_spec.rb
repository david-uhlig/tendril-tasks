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
  end
end
