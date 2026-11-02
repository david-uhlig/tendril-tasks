# frozen_string_literal: true

require "spec_helper"
require_relative "../../lookbook/flowbite_coverage"

RSpec.describe Gustwave::FlowbiteCoverage do
  subject(:coverage) { Gustwave::FlowbiteCoverage.new(manifest) }

  let(:manifest) do
    {
      "flowbite_version" => "3.1.2",
      "pages" => {
        "components/drawer" => [
          { "id" => "a", "title" => "Default drawer", "status" => "previewed", "preview" => "gustwave/drawer/default" },
          { "id" => "b", "title" => "Placement > Left drawer", "status" => "previewed", "preview" => "gustwave/drawer/default", "params" => { "placement" => "left" } },
          { "id" => "c", "title" => "Contact form", "status" => "partial", "needs" => "form" }
        ],
        "components/tables" => [
          { "id" => "d", "title" => "Table foot", "status" => "feature_gap", "needs" => "table-foot" },
          { "id" => "e", "title" => "Striped", "status" => "composable" }
        ],
        "forms/select" => [ { "id" => "f", "title" => "Select", "status" => "blocked", "needs" => "form" } ],
        "typography/text" => [ { "id" => "g", "title" => "Font size", "status" => "tailwind" } ],
        "plugins/charts" => [ { "id" => "h", "title" => "Area chart", "status" => "out_of_scope" } ]
      }
    }
  end

  it "knows the version and the pages" do
    expect(coverage.version).to eq("3.1.2")
    expect(coverage.page_keys.first).to eq("components/drawer")
  end

  describe "#examples" do
    it "returns all examples or those of a page" do
      expect(coverage.examples.size).to eq(8)
      expect(coverage.examples("components/tables").map(&:id)).to eq(%w[d e])
    end

    it "raises for an unknown page" do
      expect { coverage.examples("components/nope") }.to raise_error(KeyError)
    end
  end

  describe "#totals" do
    it "counts every status in a stable order, including those without examples" do
      expect(coverage.totals("components/tables")).to eq(
        "previewed" => 0, "composable" => 1, "tailwind" => 0, "feature_gap" => 1,
        "partial" => 0, "blocked" => 0, "out_of_scope" => 0
      )
      expect(coverage.totals.keys).to eq(described_class::STATUSES.keys)
    end
  end

  it "counts what is possible today and what is in scope" do
    expect(coverage.possible_count).to eq(4)
    expect(coverage.in_scope_count).to eq(7)
  end

  describe "#gaps" do
    it "ranks needs by examples, then name, with the pages they are on" do
      expect(coverage.gaps).to eq(
        [
          { need: "form", count: 2, pages: [ "components/drawer", "forms/select" ] },
          { need: "table-foot", count: 1, pages: [ "components/tables" ] }
        ]
      )
    end
  end

  describe "#for_scenario" do
    it "finds every example a scenario reproduces" do
      expect(coverage.for_scenario("gustwave/drawer/default").map(&:id)).to eq(%w[a b])
    end

    it "is empty for a scenario without examples" do
      expect(coverage.for_scenario("gustwave/icon/gallery")).to eq([])
    end
  end

  it "links a page to Flowbite's docs and its pinned source" do
    expect(coverage.docs_url("components/tabs")).to eq("https://flowbite.com/docs/components/tabs/")
    expect(coverage.source_url("components/tabs")).to eq(
      "https://github.com/themesberg/flowbite/blob/v3.1.2/content/components/tabs.md"
    )
  end

  describe Gustwave::FlowbiteCoverage::Example do
    let(:example_with_preview) { coverage.examples.find { _1.id == "b" } }
    let(:example_without_preview) { coverage.examples.find { _1.id == "c" } }

    it "splits its preview into the preview's path and the scenario" do
      expect(example_with_preview.preview_path).to eq("gustwave/drawer")
      expect(example_with_preview.scenario).to eq("default")
    end

    it "has no preview path or scenario without a preview" do
      expect(example_without_preview.preview_path).to be_nil
      expect(example_without_preview.scenario).to be_nil
    end

    it "labels its status" do
      expect(example_with_preview.status_label).to eq("Has a preview")
    end

    it "anchors its docs link on its deepest heading" do
      expect(example_with_preview.docs_url).to eq("https://flowbite.com/docs/components/drawer/#left-drawer")
    end
  end

  describe ".current" do
    it "reads the real manifest, whose statuses and keys it all understands" do
      current = described_class.current

      expect(current.examples).not_to be_empty
      expect(current.examples.map(&:status_label)).to all(be_a(String))
      expect(current.possible_count).to be_between(1, current.in_scope_count)
    end

    it "keeps the manifest until it changes" do
      expect(described_class.current).to equal(described_class.current)
    end
  end
end
