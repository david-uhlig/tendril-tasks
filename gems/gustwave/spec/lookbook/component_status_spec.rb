require "rails_helper"
require_relative "../../lookbook/component_status"
require_relative "../fixtures/component_status/classes"

RSpec.describe Gustwave::ComponentStatus do
  describe ".tags" do
    it "reads every @status tag in the class docstring" do
      expect(described_class.tags(ComponentStatusFixtures::Beta)).to eq([ "beta" ])
      expect(described_class.tags(ComponentStatusFixtures::Twice)).to eq(%w[alpha beta])
      expect(described_class.tags(ComponentStatusFixtures::Untagged)).to eq([])
    end

    it "reads an empty tag as an empty value" do
      expect(described_class.tags(ComponentStatusFixtures::Empty)).to eq([ "" ])
    end

    it "ignores comments separated from the class by a blank line" do
      expect(described_class.tags(ComponentStatusFixtures::Detached)).to eq([])
    end
  end

  describe ".for" do
    it "returns the status when there is exactly one valid tag" do
      expect(described_class.for(ComponentStatusFixtures::Beta)).to eq("beta")
    end

    it "returns nil for no, two, unknown or empty tags" do
      %w[Untagged Twice Unknown Empty].each do |name|
        expect(described_class.for(ComponentStatusFixtures.const_get(name))).to be_nil, name
      end
    end

    it "returns nil without a component" do
      expect(described_class.for(nil)).to be_nil
    end
  end

  describe ".components" do
    it "lists the gem's components, nested ones included, but not the base class" do
      expect(described_class.components).to include(Gustwave::Card, Gustwave::Timeline::Item)
      expect(described_class.components).not_to include(Gustwave::Component)
    end
  end

  describe ".component_for_preview" do
    it "finds the component a preview is named after" do
      expect(described_class.component_for_preview(double(name: "Gustwave::CardPreview"))).to eq(Gustwave::Card)
    end

    it "returns nil when that isn't a component" do
      expect(described_class.component_for_preview(double(name: "Gustwave::ButtonPreview"))).to be_nil
      expect(described_class.component_for_preview(double(name: "Gustwave::NothingPreview"))).to be_nil
    end
  end
end
