# frozen_string_literal: true

require "date"
require "open3"
require "rubygems"
require_relative "changelog"
require_relative "version_file"

module Release
  # The commands of bin/release. See RELEASING.md for the release process.
  class CLI
    USAGE = <<~USAGE
      Usage: bin/release COMMAND ARGUMENT

        prepare VERSION   Create the branch release/VERSION with the version bump and
                          the changelog section. Run it on main for X.Y.0, on X-Y-stable
                          for a patch release.
        tag VERSION       Tag the merged release. For X.Y.0 also create X-Y-stable and
                          a branch that starts the next version on main.
        notes VERSION     Print the changelog section of VERSION, e.g. for the GitHub release.
        backport COMMIT   Cherry-pick COMMIT onto the current branch and copy the
                          changelog entries it added.
        sync VERSION      Copy the changelog section of the patch release VERSION from
                          its tag into CHANGELOG.md and remove its entries from
                          [Unreleased]. Prints the entries it couldn't remove.
    USAGE

    class Error < StandardError; end

    # Works on the repository in the current directory, so the bin/release of main
    # can also release from a stable branch that doesn't have it yet
    def initialize(root: Dir.pwd, out: $stdout)
      @root = root
      @out = out
      @changelog_path = File.join(root, "CHANGELOG.md")
      @version_file = VersionFile.new(File.join(root, "config/version.rb"))
    end

    def run(argv)
      command, argument = argv
      raise Error, USAGE unless %w[prepare tag notes backport sync].include?(command) && argument

      public_send(command, argument)
    rescue Error, Changelog::Error => e
      warn e.message
      exit 1
    end

    def prepare(version)
      version = parse_version(version)
      base = base_branch(version)
      require_clean_tree
      require_branch(base)
      raise Error, "The tag v#{version} already exists" if git_ok?("rev-parse", "--verify", "--quiet", "refs/tags/v#{version}")

      changelog = read_changelog
      if patch?(version) && changelog.non_patch_headings.any?
        raise Error, "A patch release may only contain Fixed and Security entries. " \
                     "[Unreleased] also has: #{changelog.non_patch_headings.join(", ")}"
      end

      git("switch", "--create", "release/#{version}")
      @version_file.write(version.to_s)
      write_changelog(changelog.release(version.to_s))
      git("commit", "--all", "--message", "Release #{version}")

      say <<~NEXT
        Created release/#{version}. Review it, then open the release PR against #{base}:
          git push --set-upstream origin release/#{version}
          gh pr create --base #{base} --title "Release #{version}"
        Once it's merged, pull #{base} and run: bin/release tag #{version}
      NEXT
    end

    def tag(version)
      version = parse_version(version)
      base = base_branch(version)
      require_clean_tree
      require_branch(base)
      unless @version_file.read == version.to_s
        raise Error, "config/version.rb says #{@version_file.read}. Merge the release PR and pull #{base} first."
      end

      git("tag", "--annotate", "v#{version}", "--message", "Release #{version}")
      say "Tagged v#{version}."
      return say(<<~NEXT) if patch?(version)
        Push the tag. That opens a PR that copies the changelog section to main:
          git push origin v#{version}
          gh release create v#{version} --title v#{version} --notes "$(bin/release notes #{version})"
      NEXT

      stable = stable_branch(version)
      git("branch", stable, "v#{version}")
      start_next_version(version)
      say <<~NEXT
        Created #{stable} and #{next_branch(version)}. Push them, publish the release and
        open the PR that starts #{next_version(version)} on main:
          git push origin v#{version} #{stable}
          gh release create v#{version} --title v#{version} --notes "$(bin/release notes #{version})"
          git push --set-upstream origin #{next_branch(version)}
          gh pr create --base main --head #{next_branch(version)} --title "Start #{next_version(version)}"
      NEXT
    end

    def notes(version)
      say read_changelog.notes(version)
    end

    def backport(commit)
      require_clean_tree
      sha = git("rev-parse", "--verify", "#{commit}^{commit}").strip
      parents = git("rev-list", "--parents", "--max-count=1", sha).split.drop(1)
      mainline = parents.size > 1 ? [ "--mainline", "1" ] : []

      git_ok?("cherry-pick", "--no-commit", *mainline, sha)
      conflicts = git("diff", "--name-only", "--diff-filter=U").split - [ "CHANGELOG.md" ]
      if conflicts.any?
        raise Error, "The backport of #{sha[0, 7]} conflicts in: #{conflicts.join(", ")}. " \
                     "Resolve them, keep CHANGELOG.md as it is on this branch and commit, " \
                     "or give up with: git cherry-pick --abort"
      end

      # The changelogs of main and the stable branches differ, so the commit's
      # changelog change rarely applies. Copy the entries it added instead.
      git("checkout", "HEAD", "--", "CHANGELOG.md")
      entries = Changelog.added_entries(git("show", "#{sha}~:CHANGELOG.md"), git("show", "#{sha}:CHANGELOG.md"))
      if entries.any?
        write_changelog(read_changelog.add_unreleased(entries))
        git("add", "CHANGELOG.md")
      end
      raise Error, "#{sha[0, 7]} changes nothing on this branch" if git_ok?("diff", "--cached", "--quiet")

      message = git("log", "--max-count=1", "--format=%B", sha).strip
      git("commit", "--message", "#{message}\n\n(cherry picked from commit #{sha})")
      say "Backported #{sha[0, 7]}."
      non_patch = entries.keys - Changelog::PATCH_HEADINGS
      say "Note: patch releases only take Fixed and Security entries, but this adds: #{non_patch.join(", ")}" if non_patch.any?
    end

    def sync(version)
      version = parse_version(version)
      released = Changelog.parse(git("show", "v#{version}:CHANGELOG.md"))
      changelog = read_changelog
      unmatched = changelog.add_release(released, version.to_s)
      write_changelog(changelog)
      return if unmatched.empty?

      say "These entries of #{version} aren't in [Unreleased] word for word. Remove or reword them by hand:"
      unmatched.each { |entry| say entry }
    end

    private

    def parse_version(version)
      raise Error, "#{version} isn't a version like 1.2.3" unless version.match?(/\A\d+\.\d+\.\d+\z/)

      Gem::Version.new(version)
    end

    def patch?(version) = !version.segments[2].zero?

    def stable_branch(version) = "#{version.segments[0]}-#{version.segments[1]}-stable"

    def base_branch(version) = patch?(version) ? stable_branch(version) : "main"

    def next_version(version) = "#{version.segments[0]}.#{version.segments[1] + 1}.0.dev"

    def next_branch(version) = "chore/start-#{next_version(version).tr(".", "-")}"

    def start_next_version(version)
      git("switch", "--create", next_branch(version))
      @version_file.write(next_version(version))
      git("commit", "--all", "--message", "Start #{next_version(version)}")
    ensure
      git_ok?("switch", "main")
    end

    def require_clean_tree
      raise Error, "Commit or stash your changes first" unless git("status", "--porcelain").empty?
    end

    def require_branch(branch)
      current = git("branch", "--show-current").strip
      raise Error, "Run this on #{branch}, not #{current}" unless current == branch
    end

    def read_changelog = Changelog.parse(File.read(@changelog_path))

    def write_changelog(changelog) = File.write(@changelog_path, changelog.to_s)

    def say(text) = @out.puts(text)

    def git(*args)
      output, error, status = Open3.capture3("git", *args, chdir: @root)
      raise Error, "git #{args.join(" ")} failed: #{error}" unless status.success?

      output
    end

    def git_ok?(*args)
      _, _, status = Open3.capture3("git", *args, chdir: @root)
      status.success?
    end
  end
end
