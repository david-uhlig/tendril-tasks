require "rails_helper"
require "gustwave/test/style_snapshots"

RSpec.describe Gustwave::Test::StyleSnapshots::Snapshot do
  let(:example_class) { "from-example" }

  def record(snapshot)
    snapshot.record(self) { |html, _content, _slots| Nokogiri::HTML5.fragment(html) }
  end

  describe "#record" do
    it "renders every combination of a group's axes" do
      snapshot = described_class.new("Example")
      snapshot.group(:look, size: %i[sm lg], pill: [ false, true ]) do |size:, pill:|
        %(<span class="size-#{size} #{'rounded-full' if pill}"></span>)
      end

      expect(record(snapshot).keys).to eq [
        "look size=:sm pill=false", "look size=:sm pill=true",
        "look size=:lg pill=false", "look size=:lg pill=true"
      ]
    end

    it "records each element's tag, sorted attributes and sorted classes in document order" do
      snapshot = described_class.new("Example")
      snapshot.group(:plain) { %(<div class="p-4 flex" role="status" aria-hidden="true"><b></b><i class="z-0"></i></div>) }

      expect(record(snapshot)).to eq("plain" => [ 'div aria-hidden="true" role="status": flex p-4', "b", "i: z-0" ])
    end

    it "leaves out SVG path geometry" do
      snapshot = described_class.new("Example")
      snapshot.group(:svg) { %(<svg viewBox="0 0 24 24"><path d="M0 0h24" stroke-width="2"></path></svg>) }

      expect(record(snapshot)).to eq("svg" => [ 'svg viewBox="0 0 24 24"', 'path stroke-width="2"' ])
    end

    it "calls reset before building each combination" do
      snapshot = described_class.new("Example")
      calls = []
      snapshot.group(:reset, size: %i[sm lg]) { |size:| calls << size && "<p></p>" }
      snapshot.record(self, reset: -> { calls << :reset }) { |html, _content, _slots| Nokogiri::HTML5.fragment(html) }

      expect(calls).to eq %i[reset sm reset lg]
    end

    it "keeps nil as an axis value" do
      snapshot = described_class.new("Example")
      snapshot.group(:custom, class: nil) { |**| "<p></p>" }

      expect(record(snapshot).keys).to eq [ "custom class=nil" ]
    end

    it "runs the group's block in the example" do
      snapshot = described_class.new("Example")
      snapshot.group(:context) { %(<p class="#{example_class}"></p>) }

      expect(record(snapshot)).to eq("context" => [ "p: from-example" ])
    end

    it "raises when two groups record the same combination" do
      snapshot = described_class.new("Example")
      snapshot.group(:same) { "<p></p>" }
      snapshot.group(:same) { "<p></p>" }

      expect { record(snapshot) }.to raise_error(ArgumentError, /records same twice/)
    end
  end

  describe ".diff" do
    it "returns nil when nothing changed" do
      expect(described_class.diff({ "a" => [ "p" ] }, { "a" => [ "p" ] })).to be_nil
    end

    it "lists changed, new and removed combinations" do
      message = described_class.diff(
        { "changed" => [ "p: a" ], "removed" => [ "p" ] },
        { "changed" => [ "p: b" ], "new" => [ "p" ] }
      )

      expect(message).to eq <<~MSG.chomp
        3 combinations changed:
        ~ changed
            expected: ["p: a"]
            actual:   ["p: b"]
        - removed (removed)
        + new (new)
      MSG
    end
  end
end
