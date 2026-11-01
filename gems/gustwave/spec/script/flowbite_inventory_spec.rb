# frozen_string_literal: true

require "spec_helper"
require "stringio"
require "tmpdir"
require_relative "../../script/flowbite_inventory"

RSpec.describe Gustwave::FlowbiteInventory do
  describe ".parse" do
    it "finds an example with the heading above it" do
      markdown = <<~MD
        ## Default tabs

        Some text.

        {{< example id="default-tabs-example" github="components/tabs.md" show_dark=true >}}
        <div></div>
        {{< /example >}}
      MD

      expect(described_class.parse(markdown)).to eq([ { "id" => "default-tabs-example", "title" => "Default tabs" } ])
    end

    it "joins a subheading to its heading and resets it at the next heading" do
      markdown = <<~MD
        ## Placement

        ### Left drawer

        {{< example id="left" >}}

        ## Backdrop

        {{< example id="backdrop" >}}
      MD

      expect(described_class.parse(markdown).map { _1["title"] }).to eq([ "Placement > Left drawer", "Backdrop" ])
    end

    it "finds an indented shortcode" do
      expect(described_class.parse("## A\n  {{< example id=\"indented\" >}}\n").map { _1["id"] }).to eq([ "indented" ])
    end

    it "finds a shortcode without a space or without its closing on the same line" do
      markdown = <<~MD
        ## A

        {{<example id="no-space" >}}
        {{< example id="open-ended" github="a.md"
      MD

      expect(described_class.parse(markdown).map { _1["id"] }).to eq([ "no-space", "open-ended" ])
    end

    it "ignores the closing shortcode" do
      expect(described_class.parse("{{< /example >}}\n")).to be_empty
    end

    it "slugs the heading of an example without an id" do
      markdown = "## Modal with CRUD!\n\n{{< example github=\"a.md\" >}}\n"

      expect(described_class.parse(markdown).map { _1["id"] }).to eq([ "modal-with-crud" ])
    end

    it "keeps the ids within a page unique" do
      markdown = "## A\n{{< example id=\"same\" >}}\n{{< example id=\"same\" >}}\n"

      expect(described_class.parse(markdown).map { _1["id"] }).to eq([ "same", "same-1" ])
    end

    it "strips whitespace from headings" do
      expect(described_class.parse("## Bordered alerts \n{{< example id=\"a\" >}}\n").map { _1["title"] }).to eq([ "Bordered alerts" ])
    end
  end

  describe ".merge" do
    let(:upstream) { { "components/tabs" => [ { "id" => "a", "title" => "A" }, { "id" => "b", "title" => "B" } ] } }

    it "keeps what is recorded for a known example" do
      current = { "components/tabs" => [ { "id" => "a", "title" => "A", "status" => "previewed", "preview" => "gustwave/tabs/default" } ] }

      pages, = described_class.merge(current, upstream)

      expect(pages["components/tabs"].first).to eq(
        "id" => "a", "title" => "A", "status" => "previewed", "preview" => "gustwave/tabs/default"
      )
    end

    it "adds a new example as unclassified" do
      pages, changes = described_class.merge({}, upstream)

      expect(pages["components/tabs"].last).to eq("id" => "b", "title" => "B", "status" => "unclassified")
      expect(changes[:added]).to eq([ "components/tabs#a", "components/tabs#b" ])
    end

    it "drops and reports an example that is gone, also from a removed page" do
      current = {
        "components/tabs" => [ { "id" => "gone", "title" => "Gone", "status" => "composable" } ],
        "components/old" => [ { "id" => "old", "title" => "Old", "status" => "blocked" } ]
      }

      pages, changes = described_class.merge(current, upstream)

      expect(pages.keys).to eq([ "components/tabs" ])
      expect(changes[:removed]).to eq([ "components/tabs#gone", "components/old#old" ])
    end

    it "updates and reports a changed title" do
      current = { "components/tabs" => [ { "id" => "a", "title" => "Old", "status" => "composable" } ] }

      pages, changes = described_class.merge(current, upstream)

      expect(pages["components/tabs"].first["title"]).to eq("A")
      expect(changes[:retitled]).to eq([ "components/tabs#a" ])
    end
  end

  describe ".version" do
    it "is the pinned tag without its prefix" do
      expect(described_class.version({ ref: "v3.1.2" })).to eq("3.1.2")
    end
  end

  describe "the manifest" do
    it "reads back what it dumps, with a comment on top" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "flowbite.yml")
        pages = { "components/tabs" => [ { "id" => "é", "title" => "Tabs", "status" => "composable" } ] }
        dumped = described_class.dump_manifest("3.1.2", pages)
        File.write(path, dumped, encoding: "utf-8")

        expect(dumped).to start_with("# Every example")
        expect(described_class.read_manifest(path)).to eq("flowbite_version" => "3.1.2", "pages" => pages)
      end
    end

    it "is empty when there is no file yet" do
      expect(described_class.read_manifest("/does/not/exist.yml")).to eq("pages" => {})
    end
  end

  describe ".write_stubs" do
    it "writes a titled page per docs page, also for a hyphenated name" do
      Dir.mktmpdir do |dir|
        described_class.write_stubs({ "components/device-mockups" => [] }, dir)

        expect(File.read(File.join(dir, "components/device-mockups.html.erb"))).to eq(<<~ERB)
          ---
          title: Device mockups
          ---
          <%= render "lookbook/flowbite/page", key: "components/device-mockups" %>
        ERB
      end
    end

    it "removes the page of a docs page that is gone" do
      Dir.mktmpdir do |dir|
        described_class.write_stubs({ "components/old" => [] }, dir)
        described_class.write_stubs({ "components/new" => [] }, dir)

        expect(Dir.glob("**/*.html.erb", base: dir)).to eq([ "components/new.html.erb" ])
      end
    end
  end

  describe Gustwave::FlowbiteInventory::CLI do
    let(:out) { StringIO.new }
    let(:err) { StringIO.new }
    let(:upstream) { { "components/tabs" => [ { "id" => "a", "title" => "A" } ] } }

    before { allow(Gustwave::FlowbiteInventory).to receive(:fetch_pages).and_return(upstream) }

    it "writes the manifest and reports the changes" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "flowbite.yml")

        expect(described_class.new([], out:, err:, manifest: path).run).to eq(0)
        expect(out.string).to include("added components/tabs#a")
        expect(out.string).to include("pages 1, examples 1: added 1, removed 0, retitled 0")
        expect(Gustwave::FlowbiteInventory.read_manifest(path)).to include("flowbite_version" => "3.1.2")
        expect(File.exist?(File.join(dir, "pages/flowbite/components/tabs.html.erb"))).to be(true)
      end
    end

    it "writes nothing on a dry run" do
      Dir.mktmpdir do |dir|
        path = File.join(dir, "flowbite.yml")

        expect(described_class.new([ "--dry-run" ], out:, err:, manifest: path).run).to eq(0)
        expect(File.exist?(path)).to be(false)
        expect(Dir.exist?(File.join(dir, "pages"))).to be(false)
      end
    end

    it "fails on a bad option and on arguments" do
      expect(described_class.new([ "--nope" ], out:, err:).run).to eq(1)
      expect(described_class.new([ "extra" ], out:, err:).run).to eq(1)
      expect(err.string).to include("flowbite-inventory:")
    end

    it "fails on an unsupported source" do
      expect(described_class.new([ "--source", "https://example.com" ], out:, err:).run).to eq(1)
    end
  end
end
