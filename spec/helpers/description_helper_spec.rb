require "rails_helper"

RSpec.describe DescriptionHelper, type: :helper do
  describe "#simple_line_breaks" do
    it "joins lines with br tags" do
      expect(helper.simple_line_breaks("First\nSecond")).to eq("First<br>Second")
    end

    it "escapes markup" do
      expect(helper.simple_line_breaks("<script>alert(1)</script>")).to eq("&lt;script&gt;alert(1)&lt;/script&gt;")
    end

    it "does not double-escape entity-encoded text" do
      expect(helper.simple_line_breaks("Tom &amp; Jerry &lt;3")).to eq("Tom &amp; Jerry &lt;3")
    end

    it "returns an empty string for nil" do
      expect(helper.simple_line_breaks(nil)).to eq("")
    end
  end
end
