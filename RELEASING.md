# Releasing

Tendril Tasks follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html) and keeps one stable branch per minor version, like Rails. New work lands on `main`. Fixes for a released version are backported to its stable branch, e.g. `0-7-stable`.

## Versions

While Tendril Tasks is at `0.x`:

- **Patch releases** (`0.7.1`) only contain fixes for regressions, crashes, data loss and security issues. They add no configuration options or environment variables, deprecate nothing and contain no migrations that change behavior. Updating to a patch release is always safe.
- **Minor releases** (`0.8.0`) contain everything else: anything listed under Breaking Changes, Deprecated, Added or Changed, and every migration. A minor release may contain breaking changes, each with an upgrade note in the changelog.
- **Deprecations** come one minor release before the removal. Deprecate in `0.8.0`, remove in `0.9.0`.
- **Required upgrade stops**: when a minor release can't be reached directly, e.g. `0.9.0` requires `0.8.x` first, the first entry under its Breaking Changes says so, and so does its GitHub release.
- **1.0.0** comes once minor releases no longer break anything.

`main` always carries the next minor version with a `.dev` suffix, e.g. `0.8.0.dev`.

## Supported Versions

Only the latest minor version receives fixes, for bugs and security issues alike. Once `0.8.0` is out, `0-7-stable` receives nothing more.

**Security exception:** when the latest minor version contains breaking changes, a fix for a critical or high severity vulnerability is also released for the previous minor version, so updating doesn't force a breaking change on anyone just to stay secure. This is a single patch release, not continued support.

## Changelog

[CHANGELOG.md](CHANGELOG.md) follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and only lists changes that users and admins notice. Each PR adds its entries under `[Unreleased]`, in this order: Breaking Changes, Deprecated, Added, Changed, Removed, Fixed, Security.

## Backports

Fix on `main` first, then backport:

1. Label the PR with `backport 0-7-stable` before merging it. Once it's merged, the [Backport workflow](.github/workflows/backport.yml) opens a PR against `0-7-stable` that cherry-picks the commit and copies its changelog entries.
2. For a label added after the merge, run `gh workflow run backport.yml -f pr=123`.
3. If the cherry-pick conflicts, the workflow comments on the PR instead. Backport by hand on a branch off `0-7-stable`, using `bin/release` of a `main` checkout:

   ```shell
   git switch --create fix/backport-123-to-0-7-stable origin/0-7-stable
   ../tendril-tasks-main/bin/release backport COMMIT
   ```

Only backport what a patch release may contain. `bin/release prepare` refuses a patch release whose `[Unreleased]` has entries other than Fixed and Security.

## Releasing a Minor Version

On an up-to-date `main`:

1. `bin/release prepare 0.8.0` creates the branch `release/0.8.0`, sets the version and turns `[Unreleased]` into the `0.8.0` section of the changelog.
2. Review it, push it and merge the release PR.
3. Pull `main` and run `bin/release tag 0.8.0`. It tags `v0.8.0`, creates `0-8-stable` from the tag and the branch `chore/start-0-9-0-dev`, which sets `main` to `0.9.0.dev`.
4. Push the tag and the stable branch, publish the GitHub release and merge the PR that starts `0.9.0.dev`. `bin/release tag` prints the commands.

## Releasing a Patch Version

On an up-to-date `0-7-stable`, using `bin/release` of a `main` checkout if `0-7-stable` doesn't have it:

1. `bin/release prepare 0.7.3` creates the branch `release/0.7.3` with the version and the changelog section.
2. Review it, push it and merge the release PR into `0-7-stable`.
3. Pull `0-7-stable` and run `bin/release tag 0.7.3`.
4. Push the tag and publish the GitHub release. `bin/release tag` prints the commands.

Pushing the tag runs the [Sync changelog workflow](.github/workflows/sync-changelog.yml). It opens a PR that adds the `0.7.3` section to the changelog on `main` and removes its entries from `[Unreleased]`. Entries that were reworded on `main` can't be matched, so the PR lists them for you to remove by hand. GitHub runs the workflow from the tagged commit, so it only runs for stable branches that have it. Otherwise, run `bin/release sync 0.7.3` on a branch off `main`.
