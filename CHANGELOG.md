# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Security
- Improve authentication and authorization safeguards.
- Fix an authorization flaw that allowed footer settings to be updated or deleted without administrator privileges.
- Prevent unsafe footer links from being added and displayed to prevent XSS attacks.

### Changed
- Upgrade dependencies: Ruby 3.4.10, ViewComponent 4.15, etc.

## [0.5.1] - 2026-07-30

### Changed
- Update dependencies to address various upstream security vulnerabilities.

## [0.5.0] - 2026-04-24

### Breaking Changes
- Change the project’s license to the source-available O’SaaSy License Agreement. The commercial right to offer the software as a service (SaaS) is reserved exclusively for the copyright holder. See the license agreement for the rights granted for other uses.

- The `ROCKET_CHAT_NOTIFIER_*` environment variables have been renamed to `ROCKET_CHAT_API_*`. If you send notifications to Rocket.Chat, update `config/deploy.yml` and `.kamal/secrets`.

### Changed
- Sort projects by their most recently published task on the `/projects` and `/tasks` pages.
- Sort projects alphabetically on the creation and editing forms.
- Upgrade dependencies: Rails 8.1.2, Bundler 4.0, Puma 7.0, Kamal 2.8, ViewComponent 4.0, noticed 3.0, etc.

## [0.4.2] - 2025-10-12

### Security
- Upgrade dependencies to fix upstream vulnerabilities: CVE-2025-61919 and CVE-2025-61780.

## [0.4.1] - 2025-10-07

### Security
- Upgrade dependencies: Ruby 3.4.7, etc. Addresses upstream vulnerabilities: CVE-2025-61772, CVE-2025-61771, and CVE-2025-61770.

## [0.4.0] - 2025-09-06

### Changed
- Remove the committed `node_modules` directory and update the Dockerfile to install packages with `npm ci` during image builds.

### Security
- Upgrade dependencies: Ruby 3.4.5, etc. Addresses upstream vulnerabilities: CVE-2025-24293 and CVE-2025-55193.

## [0.3.2] - 2025-07-23

### Security
- Upgrade dependencies to address upstream vulnerabilities [GHSA-353f-x4gh-cqq8](https://github.com/advisories/GHSA-353f-x4gh-cqq8) and CVE-2025-49007.

## [0.3.1] - 2025-05-29

### Changed
- Make minor visual changes to badges.

## [0.3.0] - 2025-05-16

### Added
- Add storage monitoring using the [Active Storage Dashboard](https://github.com/giovapanasiti/active_storage_dashboard) gem.
- Add icons to the avatar menu.

## [0.2.7] - 2025-05-09

### Security
- Upgrade dependencies to address upstream vulnerabilities: CVE-2025-46727 and CVE-2025-46336.

## [0.2.6] - 2025-04-22

### Fixed
- Fix footer caching.

## [0.2.5] - 2025-04-06

### Fixed
- Fix the Git commit hash not showing in Kamal deployments.
- Fix Docker image builds failing because the `libyaml-dev` dependency was missing.

## [0.2.4] - 2025-04-06

### Added
- Add versioning and changelog management.

### Changed
- Upgrade dependencies: Ruby 3.4.2.

[unreleased]: https://github.com/david-uhlig/tendril-tasks/compare/v0.5.1...HEAD
[0.5.1]: https://github.com/david-uhlig/tendril-tasks/compare/v0.5.0...v0.5.1
[0.5.0]: https://github.com/david-uhlig/tendril-tasks/compare/v0.4.2...v0.5.0
[0.4.2]: https://github.com/david-uhlig/tendril-tasks/compare/v0.4.1...v0.4.2
[0.4.1]: https://github.com/david-uhlig/tendril-tasks/compare/v0.4.0...v0.4.1
[0.4.0]: https://github.com/david-uhlig/tendril-tasks/compare/v0.3.2...v0.4.0
[0.3.2]: https://github.com/david-uhlig/tendril-tasks/compare/v0.3.1...v0.3.2
[0.3.1]: https://github.com/david-uhlig/tendril-tasks/compare/v0.3.0...v0.3.1
[0.3.0]: https://github.com/david-uhlig/tendril-tasks/compare/v0.2.7...v0.3.0
[0.2.7]: https://github.com/david-uhlig/tendril-tasks/compare/v0.2.6...v0.2.7
[0.2.6]: https://github.com/david-uhlig/tendril-tasks/compare/v0.2.5...v0.2.6
[0.2.5]: https://github.com/david-uhlig/tendril-tasks/compare/v0.2.4...v0.2.5
[0.2.4]: https://github.com/david-uhlig/tendril-tasks/releases/tag/v0.2.4
