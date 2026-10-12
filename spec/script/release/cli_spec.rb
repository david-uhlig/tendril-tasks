# frozen_string_literal: true

require "open3"
require "stringio"
require "tmpdir"
require_relative "../../../script/release/cli"

RSpec.describe Release::CLI do
  let(:repository) { Release::Changelog::REPOSITORY }
  let(:out) { StringIO.new }
  let(:cli) { described_class.new(root: @root, out:) }

  around do |example|
    Dir.mktmpdir do |root|
      @root = root
      example.run
    end
  end

  # A repository with 0.7.0 released from main and 0-7-stable branched off it
  before do
    git("init", "--quiet", "--initial-branch=main")
    git("config", "user.name", "Test")
    git("config", "user.email", "test@example.com")
    git("config", "commit.gpgSign", "false")
    git("config", "tag.gpgSign", "false")
    write("config/version.rb", %(module TendrilTasks\n  VERSION = "0.7.0".freeze\nend\n))
    write("CHANGELOG.md", <<~MARKDOWN)
      # Changelog

      ## [Unreleased]

      ## [0.7.0] - 2026-10-09

      ### Added
      - A feature.

      [unreleased]: #{repository}/compare/v0.7.0...HEAD
      [0.7.0]: #{repository}/compare/v0.6.1...v0.7.0
    MARKDOWN
    commit("Release 0.7.0")
    git("tag", "v0.7.0")
    git("branch", "0-7-stable")
  end

  def git(*args)
    output, error, status = Open3.capture3("git", *args, chdir: @root)
    raise "git #{args.join(" ")}: #{error}" unless status.success?

    output
  end

  def write(path, content)
    FileUtils.mkdir_p(File.dirname(File.join(@root, path)))
    File.write(File.join(@root, path), content)
  end

  def read(path) = File.read(File.join(@root, path))

  def commit(message)
    git("add", "--all")
    git("commit", "--quiet", "--message", message)
    git("rev-parse", "HEAD").strip
  end

  def add_unreleased(heading, entry)
    write("CHANGELOG.md", read("CHANGELOG.md").sub("## [Unreleased]\n", "## [Unreleased]\n\n### #{heading}\n- #{entry}\n"))
  end

  def fix_on_main
    write("app.rb", "fixed\n")
    add_unreleased("Fixed", "A fix.")
    commit("Fix a bug (#1)")
  end

  describe "#backport" do
    it "cherry-picks the commit and copies its changelog entries" do
      add_unreleased("Changed", "A change on main only.")
      commit("Change something")
      fix = fix_on_main
      git("switch", "--quiet", "0-7-stable")

      cli.backport(fix)

      expect(read("app.rb")).to eq("fixed\n")
      expect(Release::Changelog.parse(read("CHANGELOG.md")).entries).to eq("Fixed" => [ "- A fix." ])
      expect(git("log", "-1", "--format=%B")).to include("Fix a bug (#1)", "(cherry picked from commit #{fix})")
    end

    it "stops on a conflict outside the changelog" do
      write("app.rb", "on main\n")
      commit("Change app.rb on main")
      fix = fix_on_main
      git("switch", "--quiet", "0-7-stable")
      write("app.rb", "on stable\n")
      commit("Change app.rb on stable")

      expect { cli.backport(fix) }.to raise_error(Release::CLI::Error, /conflicts in: app.rb/)
    end
  end

  describe "#prepare" do
    it "creates the release branch with the version bump and the changelog section" do
      git("switch", "--quiet", "0-7-stable")
      add_unreleased("Fixed", "A fix.")
      commit("Fix a bug")

      cli.prepare("0.7.1")

      expect(git("branch", "--show-current").strip).to eq("release/0.7.1")
      expect(git("log", "-1", "--format=%s").strip).to eq("Release 0.7.1")
      expect(read("config/version.rb")).to include(%(VERSION = "0.7.1"))
      expect(read("CHANGELOG.md")).to include("## [Unreleased]\n\n## [0.7.1] - #{Date.today.iso8601}\n\n### Fixed\n- A fix.")
    end

    it "refuses a patch release with entries other than Fixed and Security" do
      git("switch", "--quiet", "0-7-stable")
      add_unreleased("Added", "A feature.")
      commit("Add a feature")

      expect { cli.prepare("0.7.1") }.to raise_error(Release::CLI::Error, /only contain Fixed and Security.*Added/)
    end

    it "refuses to run on the wrong branch" do
      expect { cli.prepare("0.7.1") }.to raise_error(Release::CLI::Error, "Run this on 0-7-stable, not main")
    end
  end

  describe "#tag" do
    it "tags a patch release" do
      git("switch", "--quiet", "0-7-stable")
      add_unreleased("Fixed", "A fix.")
      commit("Fix a bug")
      cli.prepare("0.7.1")
      git("switch", "--quiet", "0-7-stable")
      git("merge", "--quiet", "--ff-only", "release/0.7.1")

      cli.tag("0.7.1")

      expect(git("tag", "--list", "v0.7.1").strip).to eq("v0.7.1")
    end

    it "refuses to tag before the release is merged" do
      expect { cli.tag("0.8.0") }.to raise_error(Release::CLI::Error, /says 0.7.0/)
    end

    it "creates the stable branch and starts the next version for a minor release" do
      add_unreleased("Added", "Another feature.")
      commit("Add a feature")
      cli.prepare("0.8.0")
      git("switch", "--quiet", "main")
      git("merge", "--quiet", "--ff-only", "release/0.8.0")

      cli.tag("0.8.0")

      expect(git("rev-parse", "0-8-stable")).to eq(git("rev-parse", "v0.8.0^{commit}"))
      expect(git("show", "chore/start-0-9-0-dev:config/version.rb")).to include(%(VERSION = "0.9.0.dev"))
      expect(git("branch", "--show-current").strip).to eq("main")
    end
  end

  describe "#sync" do
    it "copies the section of a patch release to main and reports reworded entries" do
      fix = fix_on_main
      add_unreleased("Fixed", "A fix, worded for main.")
      commit("Reword")
      git("switch", "--quiet", "0-7-stable")
      cli.backport(fix)
      add_unreleased("Fixed", "A fix, worded for 0.7.x.")
      commit("Fix another bug")
      cli.prepare("0.7.1")
      git("switch", "--quiet", "0-7-stable")
      git("merge", "--quiet", "--ff-only", "release/0.7.1")
      cli.tag("0.7.1")
      git("switch", "--quiet", "main")

      cli.sync("0.7.1")

      changelog = Release::Changelog.parse(read("CHANGELOG.md"))
      expect(changelog.versions.map(&:to_s)).to eq([ "0.7.1", "0.7.0" ])
      expect(changelog.entries).to eq("Fixed" => [ "- A fix, worded for main." ])
      expect(changelog.link("0.7.1")).to eq("#{repository}/compare/v0.7.0...v0.7.1")
      expect(out.string).to include("- A fix, worded for 0.7.x.")
    end
  end
end
