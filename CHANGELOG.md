# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Breaking Changes
- `ROCKET_CHAT_AUTHORIZE_URL` and `ROCKET_CHAT_TOKEN_URL` are applied to sign in with Rocket.Chat. Before, they were ignored and the default endpoints were always used. If you set either one, check that it points to your Rocket.Chat workspace's endpoints before upgrading, or remove it to keep the defaults. Otherwise, sign in with Rocket.Chat stops working.

### Deprecated
- `APP_TITLE`. Set the site name and tagline under Admin → Site instead, then remove `APP_TITLE`. Until then, it still replaces the title of the home page, and a warning is logged on start.

### Added
- Set `SOLID_QUEUE_MODE=async` together with `SOLID_QUEUE_IN_PUMA` to run background jobs in threads of the web server's process instead of four separate processes, which reduces memory use. The queue database then uses a pool of 10 connections, configurable with `SOLID_QUEUE_DB_POOL`.
- Set a label for the navigation that differs from the site name, e.g. a short name next to the logo. Leave it blank to show the site name.
- Set a tagline for the site under Admin → Site. Leave it blank to show the default tagline in the language of the page.
- The home page shows how many tasks are open, how many initiatives there are and how many tasks are new in the last two weeks. Signed in users also see the three most recently published tasks. A "How it works" section explains the steps from browsing initiatives to expressing interest in a task.
- The window listing a task's contact people has a button to go to the task.
- The home page shows the introduction on a full-width picture, darkened so the text stays readable on light pictures too. By default, it's a photo by Anna Schroeder on Unsplash, credited in its corner. Upload your own picture under Admin → Site, e.g. a photo of your people in action. It's scaled down and saved as WebP, so the home page loads fast also with photos straight from the camera.
- Set your own headline and introduction for the home page under Admin → Site, including the part of the headline shown in color. Leave them blank to show the default text in the language of the page.

### Changed
- Profile photos are downloaded from Rocket.Chat and served by Tendril Tasks, so browsers no longer load them from the Rocket.Chat workspace. Photos are downloaded on sign in and refreshed every night, so existing users get theirs within a day of upgrading. Until then, and for users whose photo can't be downloaded, a placeholder is shown.
- Upgrade to Ruby 4.0.7. If you run the app outside the Docker image, install Ruby 4.0.7 first, e.g. with `mise install`.
- The admin page "Branding" is now called "Site". It sets the site name separately from the logo and the label in the navigation. The site name is required now. Existing names, logos and settings are kept.
- The browser tab shows the title of the page and the site name, e.g. "Water the plants - Tendril Tasks", or the site name and tagline on the home page, e.g. "Tendril Tasks - growing beyond ourselves together". Before, every page showed "TendrilTasks - growing beyond ourselves together".
- The introduction on the home page is shorter.
- The default headline and introduction on the home page no longer mention the RCB or a club. To keep the previous text, enter it under Admin → Site.
- The task overview and the initiative pages show tasks in the same compact cards as the home page. On the task overview, the cards show a longer part of the description. The "Read More" button is gone, because the title, description and button already lead to the task.
- The buttons below the introduction on the home page lead to the next step. Signed in users go to "Find a task" and, once they applied for a task, to "My applications", otherwise to the initiatives. Visitors sign in or read how it works first.
- The navigation is calmer. The label next to the logo is plain bold text behind a thin divider, also on the sign in page. The links sit next to the user menu or the login button, and the user's picture has a white ring with a soft shadow instead of a colored one.

## [0.7.2] - 2026-10-12

### Fixed
- Sign in with Rocket.Chat works again in Chrome and other Chromium-based browsers. The Content Security Policy blocked the redirect to the Rocket.Chat workspace since 0.6.0.
- Editing an existing legal page, e.g. the imprint, shows "Edit Imprint" as the heading instead of "Create Imprint".
- On phones, the navigation shows only the logo, without the brand name, so the user menu stays on the same line instead of wrapping below a long brand name.

## [0.7.1] - 2026-10-10

### Fixed
- Keyboard navigation stays within an open dialog and returns to where it was once the dialog closes.
- "Save & New" on the task form preselects the topic and the coordinators of the task just saved in the next task form.
- Saving a task or project without changes no longer shows an "updated" message.
- Saving a task or project, or the contact people dialog, no longer fails with a "not found" page when a selected contact person was deleted in the meantime.
- Saving a task or project without any contact people shows a validation error instead of silently keeping the previous contact people.
- Topics are listed by their most recently published task. Tasks scheduled for later no longer move their topic to the top.
- Content Security Policy sources set in `config.x.content_security_policy` are applied, and space-separated sources are split into separate sources.
- Sign in with Rocket.Chat works when `ROCKET_CHAT_HOST` is set without `https://` or with a trailing slash.
- Rocket.Chat notifications are only sent when `ROCKET_CHAT_API_HOST` is set, instead of being sent to `example.com` when only the user ID and token are set.
- Saving the brand name or the copyright notice shows an error instead of a success message when it can't be saved. The brand name is limited to 100 characters and the copyright notice to 255.
- The footer is updated when its links or a legal page are deleted, instead of still showing them.
- The footer is shown in the current language after the default language changes, instead of the previously cached one.
- Saving the footer sitemap with an incomplete link or category shows a validation error instead of failing. The copyright notice keeps its value when the sitemap can't be saved.
- Saving a brand name, copyright notice or footer sitemap no longer fails when it's saved twice at the same time.

## [0.7.0] - 2026-10-09

### Added
- Celebrate a user's contribution with a short fireworks animation when they sign up for a task.
- Delete confirmation dialogs briefly disable the delete button to prevent accidental deletions.
- Underline, color highlight, tables and dividers in descriptions and legal pages.
- The Kamal and Docker Compose sample configurations include a health check for the web container, so deploys wait until the app is up.

### Changed
- Replace the Trix rich text editor with Lexxy. Existing content stays as it is. Headings are limited to four levels (H1–H4); existing H5 and H6 headings are still displayed.
- Upgrade dependencies: Tailwind CSS 4, tailwind_merge 1.5, Flowbite 3.1, Lexxy 1.0.

### Fixed
- Notifications stay visible after scrolling down the page.
- Coordinators can change an application's status with the keyboard.
- The arrow icon on project and task contact buttons is drawn completely.
- Screen readers announce the page language, the close buttons of all dialogs, link address fields and footer link fields in the configured language.
- The email address and username on the profile page are shown as readable values instead of faint placeholders.
- Menu entries, buttons and notifications that were always shown in German or English follow the configured language.
- The footer link categories in the admin area are listed in the same order as they appear in the footer.
- Application statuses in English are shown without quotation marks.
- The visibility explainer names the published task or initiative in English instead of showing a raw placeholder.

### Security
- Escape the project title in the task section headline on the project page to prevent XSS attacks.
- Limit comments on task applications to 2,000 characters.

## [0.6.1] - 2026-10-03

### Security
- Only signed-in editors, admins, and coordinators can upload files. Uploads are limited to images, videos, audio files, and PDFs of up to 10 MB each; SVG images are not allowed. Uploaded files that are never attached are deleted after two days.
- Coordinators can no longer set an application's status to "withdrawn".

## [0.6.0] - 2026-10-02

### Breaking Changes
- Add the PKCE configuration option `ROCKET_CHAT_PKCE` (default: `false`). This change disables PKCE by default because Rocket.Chat `>= 7.4.0` introduced a bug that breaks third-party OAuth integrations. A partial fix is available for Rocket.Chat `>= 8.0.0`, but PCKE flows remain affected. To enable PKCE once Rocket.Chat fixes the bug, set `ROCKET_CHAT_PKCE = "true"` in the `.env` or Kamal `deploy.yml` file.
- SVG brand logos are no longer supported for security reasons. Please reupload your brand logo in one of the supported formats. 

### Security
- Improve authentication and authorization safeguards.
- Fix an authorization flaw that allowed footer settings to be updated or deleted without administrator privileges.
- Configure an extendable base Content Security Policy (CSP) to mitigate XSS attacks.
- Prevent unsafe footer links from being added and displayed to prevent XSS attacks.

### Fixed
- Fix configuration examples. Rename removed `ROCKET_CHAT_NOTIFIER_*` configuration variables to `ROCKET_CHAT_API_*`. See `0.5.0` notes.
- Fix missing translations.
- Return a not-found response when an inaccessible task application is updated or withdrawn.
- Handle missing task applications and unauthorized status updates with appropriate not-found responses instead of server errors.

### Added
- Allow users to sign out from all sessions and reset all remember me tokens through their profile page.
- German translations in authorization flows (devise).
- Three new solid icons from Flowbite Icons: envelope, info-circle, and user-circle. 

### Changed
- Rename Kamal configuration and secrets example files to carry the `.sample` extension (i.e. `config/deploy.yml.sample` and `.kamal/secrets.sample`). The regular config files are now ignored via `.gitignore` to prevent accidental repository check-in. 
- Replace `APP_HOST` and `APP_PORT` with `APP_BASE_URL`. Continues accepting the legacy variables for now; emits a deprecation warning; support will be removed in a future release.
- Improve German translations for consistency and clarity.
- Replace inline SVG with permanent icon assets on the user's profile page.
- Reduce Docker image size by ~30%.
- Upgrade dependencies: Ruby 3.4.11, ViewComponent 4.15, etc.

### Removed
- Unused English translations.

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

[unreleased]: https://github.com/david-uhlig/tendril-tasks/compare/v0.7.0...HEAD
[0.7.2]: https://github.com/david-uhlig/tendril-tasks/compare/v0.7.1...v0.7.2
[0.7.1]: https://github.com/david-uhlig/tendril-tasks/compare/v0.7.0...v0.7.1
[0.7.0]: https://github.com/david-uhlig/tendril-tasks/compare/v0.6.1...v0.7.0
[0.6.1]: https://github.com/david-uhlig/tendril-tasks/compare/v0.6.0...v0.6.1
[0.6.0]: https://github.com/david-uhlig/tendril-tasks/compare/v0.5.1...v0.6.0
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
