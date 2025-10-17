## Unreleased

* Order initiatives by the latest published task on `/projects` and `/tasks` pages
* Order initiatives alphabetically on create and edit forms

## 0.4.2

* Fix CVE-2025-61919 and CVE-2025-61780

## 0.4.1

* Fix CVE-2025-61772, CVE-2025-61771, and CVE-2025-61770
* Update Ruby to 3.4.7

## 0.4.0

* Remove `node_modules` directory from repository in favor of rebuilding npm packages on demand with `npm ci`. The change is reflected in the `Dockerfile`.
* Fix CVE-2025-24293 and CVE-2025-55193
* Update Ruby to 3.4.5

## 0.3.2

* Fix [GHSA-353f-x4gh-cqq8](https://github.com/advisories/GHSA-353f-x4gh-cqq8) and CVE-2025-49007

## 0.3.1

* Minor visual changes on badges

## 0.3.0

* Introduce storage monitoring through the [Active Storage Dashboard](https://github.com/giovapanasiti/active_storage_dashboard) gem
* Add menu icons to avatar menu

## 0.2.7

* Fix CVE-2025-46727 and CVE-2025-46336

## 0.2.6

* Fix footer caching

## 0.2.5

* Fix git commit hash not showing in Kamal deployments
* Fix Dockerfile not building due to missing `libyaml-dev` dependency

## 0.2.4

* Introduce versioning and changelog management
* Bump Ruby to 3.4.2

