# frozen_string_literal: true

require_relative "../../../script/release/changelog"

RSpec.describe Release::Changelog do
  let(:repository) { described_class::REPOSITORY }
  let(:text) do
    <<~MARKDOWN
      # Changelog

      Intro.

      ## [Unreleased]

      ### Added
      - A feature.

      ### Fixed
      - Fix one.
      - Fix two,
        continued.

      ## [0.7.0] - 2026-10-09

      ### Fixed
      - Old fix.

      [unreleased]: #{repository}/compare/v0.7.0...HEAD
      [0.7.0]: #{repository}/compare/v0.6.1...v0.7.0
    MARKDOWN
  end
  let(:changelog) { described_class.parse(text) }

  it "writes the changelog back unchanged" do
    expect(changelog.to_s).to eq(text)
  end

  describe "#entries" do
    it "groups the entries by subsection, including continuation lines" do
      expect(changelog.entries).to eq(
        "Added" => [ "- A feature." ],
        "Fixed" => [ "- Fix one.", "- Fix two,\n  continued." ]
      )
    end

    it "merges repeated subsections" do
      changelog = described_class.parse(text.sub("## [0.7.0]", "### Fixed\n- Fix three.\n\n## [0.7.0]"))

      expect(changelog.entries["Fixed"]).to eq([ "- Fix one.", "- Fix two,\n  continued.", "- Fix three." ])
    end
  end

  describe "#non_patch_headings" do
    it "lists the subsections a patch release must not contain" do
      expect(changelog.non_patch_headings).to eq([ "Added" ])
    end
  end

  describe "#release" do
    before { changelog.release("0.8.0", date: Date.new(2026, 10, 20)) }

    it "turns [Unreleased] into the new version and starts an empty [Unreleased]" do
      expect(changelog.to_s).to include(<<~MARKDOWN)
        ## [Unreleased]

        ## [0.8.0] - 2026-10-20

        ### Added
        - A feature.
      MARKDOWN
    end

    it "updates the links" do
      expect(changelog.to_s).to end_with(<<~MARKDOWN)
        [unreleased]: #{repository}/compare/v0.8.0...HEAD
        [0.8.0]: #{repository}/compare/v0.7.0...v0.8.0
        [0.7.0]: #{repository}/compare/v0.6.1...v0.7.0
      MARKDOWN
    end

    it "refuses to release without entries" do
      expect { changelog.release("0.8.1") }.to raise_error(described_class::Error, /no entries/)
    end
  end

  describe "#notes" do
    it "returns the section under What's Changed with a link that compares it to the previous release" do
      changelog.release("0.8.0")

      expect(changelog.notes("0.8.0")).to eq(<<~MARKDOWN.chomp)
        ## What's Changed

        ### Added
        - A feature.

        ### Fixed
        - Fix one.
        - Fix two,
          continued.

        **Full Changelog**: #{repository}/compare/v0.7.0...v0.8.0
      MARKDOWN
    end

    it "compares to the latest patch release of the previous minor version" do
      changelog = described_class.parse(text.sub("## [0.7.0]", "## [0.7.1] - 2026-10-10\n\n### Fixed\n- Patch fix.\n\n## [0.7.0]"))
      changelog.release("0.8.0")

      expect(changelog.notes("0.8.0")).to end_with("compare/v0.7.1...v0.8.0")
      expect(changelog.notes("0.7.1")).to end_with("compare/v0.7.0...v0.7.1")
    end

    it "leaves out the comparison for the first release in the changelog" do
      expect(changelog.notes("0.7.0")).to eq("## What's Changed\n\n### Fixed\n- Old fix.")
    end
  end

  describe "#add_release" do
    let(:stable) do
      described_class.parse(<<~MARKDOWN)
        # Changelog

        ## [Unreleased]

        ## [0.7.1] - 2026-10-10

        ### Fixed
        - Fix one.
        - Reworded fix.

        ## [0.7.0] - 2026-10-09

        ### Fixed
        - Old fix.

        [unreleased]: #{repository}/compare/v0.7.1...HEAD
        [0.7.1]: #{repository}/compare/v0.7.0...v0.7.1
        [0.7.0]: #{repository}/compare/v0.6.1...v0.7.0
      MARKDOWN
    end

    it "inserts the section below [Unreleased] and removes its entries from [Unreleased]" do
      changelog.add_release(stable, "0.7.1")

      expect(changelog.to_s).to include(<<~MARKDOWN)
        ## [Unreleased]

        ### Added
        - A feature.

        ### Fixed
        - Fix two,
          continued.

        ## [0.7.1] - 2026-10-10

        ### Fixed
        - Fix one.
        - Reworded fix.

        ## [0.7.0] - 2026-10-09
      MARKDOWN
    end

    it "adds the link and keeps [unreleased] unchanged" do
      changelog.add_release(stable, "0.7.1")

      expect(changelog.to_s).to end_with(<<~MARKDOWN)
        [unreleased]: #{repository}/compare/v0.7.0...HEAD
        [0.7.1]: #{repository}/compare/v0.7.0...v0.7.1
        [0.7.0]: #{repository}/compare/v0.6.1...v0.7.0
      MARKDOWN
    end

    it "returns the entries it couldn't find in [Unreleased]" do
      expect(changelog.add_release(stable, "0.7.1")).to eq([ "- Reworded fix." ])
    end

    it "doesn't add the section twice" do
      changelog.add_release(stable, "0.7.1")

      expect { changelog.add_release(stable, "0.7.1") }.not_to change(changelog, :to_s)
    end
  end

  describe "#add_unreleased" do
    it "adds entries to existing and new subsections in the usual order" do
      changelog.add_unreleased("Security" => [ "- Escape." ], "Fixed" => [ "- Fix one.", "- Fix three." ])

      expect(changelog.entries).to eq(
        "Added" => [ "- A feature." ],
        "Fixed" => [ "- Fix one.", "- Fix two,\n  continued.", "- Fix three." ],
        "Security" => [ "- Escape." ]
      )
    end
  end

  describe ".added_entries" do
    it "returns the entries the second changelog adds to [Unreleased]" do
      after = text.sub("- Fix one.", "- Fix one.\n- Fix new.").sub("### Fixed", "### Breaking Changes\n- Break.\n\n### Fixed")

      expect(described_class.added_entries(text, after)).to eq(
        "Breaking Changes" => [ "- Break." ],
        "Fixed" => [ "- Fix new." ]
      )
    end
  end
end
