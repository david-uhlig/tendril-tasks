# frozen_string_literal: true

require "rails_helper"
require_relative "../../script/flowbite_inventory"

# The manifest behind Lookbook's Flowbite coverage pages. Keeps it from drifting
# from the previews: a renamed scenario or an unclassified example fails here.
RSpec.describe "The Flowbite manifest" do
  statuses = %w[previewed composable tailwind feature_gap partial blocked out_of_scope].freeze
  # Missing components and features that examples are waiting for.
  needs = %w[
    accordion blockquote bottom-navigation breadcrumb carousel chat-bubble clipboard datepicker footer form
    jumbotron list list-group mega-menu pagination progress rating search-input sidebar skeleton speed-dial-menu
    stepper table-foot video
  ].freeze
  keys = %w[id title status preview params needs note].freeze

  let(:manifest) { Gustwave::FlowbiteInventory.read_manifest }
  let(:entries) do
    manifest.fetch("pages").flat_map do |page, examples|
      examples.map { |example| example.merge("key" => "#{page}##{example["id"]}") }
    end
  end
  let(:scenarios) do
    ViewComponent::Preview.all.flat_map do |preview|
      preview.examples.map { |example| "#{preview.preview_name}/#{example}" }
    end
  end

  def keys_of(entries)
    entries.map { _1["key"] }
  end

  it "is pinned to the version the importer reads" do
    expect(manifest["flowbite_version"]).to eq(Gustwave::FlowbiteInventory.version)
  end

  it "has examples" do
    expect(entries).not_to be_empty
  end

  it "classifies every example" do
    expect(keys_of(entries.reject { statuses.include?(_1["status"]) })).to be_empty
  end

  it "uses only known keys" do
    expect(keys_of(entries.reject { (_1.keys - [ "key" ] - keys).empty? })).to be_empty
  end

  it "keeps the ids within a page unique" do
    duplicates = manifest.fetch("pages").select { |_page, examples| examples.map { _1["id"] }.uniq.size != examples.size }

    expect(duplicates.keys).to be_empty
  end

  it "has a generated Lookbook page for every page, and no others" do
    pages = Dir.glob("**/*.html.erb", base: Gustwave::Engine.root.join("lookbook/pages/flowbite")).map { _1.delete_suffix(".html.erb") }

    expect(pages).to match_array(manifest.fetch("pages").keys)
  end

  it "gives every previewed example a preview" do
    expect(keys_of(entries.select { _1["status"] == "previewed" && _1["preview"].blank? })).to be_empty
  end

  it "points every preview at a real scenario" do
    missing = entries.select { _1["preview"].present? }.reject { scenarios.include?(_1["preview"]) }

    expect(missing.map { "#{_1["key"]} -> #{_1["preview"]}" }).to be_empty
  end

  it "only gives a preview to previewed and partial examples" do
    expect(keys_of(entries.select { _1["preview"].present? && %w[previewed partial].exclude?(_1["status"]) })).to be_empty
  end

  it "only gives params to an example with a preview" do
    expect(keys_of(entries.select { _1["params"].present? && _1["preview"].blank? })).to be_empty
  end

  it "says what a gap, a partial or a blocked example needs" do
    waiting = entries.select { %w[feature_gap partial blocked].include?(_1["status"]) }

    expect(keys_of(waiting.reject { needs.include?(_1["needs"]) })).to be_empty
  end

  it "only says what an example needs when it is waiting for it" do
    expect(keys_of(entries.select { _1["needs"].present? && %w[feature_gap partial blocked].exclude?(_1["status"]) })).to be_empty
  end
end
