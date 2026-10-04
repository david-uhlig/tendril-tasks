[license]: LICENSE.md
[contributing]: CODE_OF_CONDUCT.md
[release]: https://github.com/david-uhlig/tendril-tasks/releases

# <img src="app/assets/images/brand/logo.svg" height="28"> Tendril Tasks

_Together, individual efforts intertwine, sparking growth that allows the entire collective to flourish._

## About

[![Static Badge](https://img.shields.io/badge/License-O'Saasy-gold)][license]
[![GitHub Release](https://img.shields.io/github/v/release/david-uhlig/tendril-tasks)][release]
[![CI](https://github.com/david-uhlig/tendril-tasks/actions/workflows/ci.yml/badge.svg)](https://github.com/david-uhlig/tendril-tasks/actions/workflows/ci.yml)

Tendril Tasks is a task distribution application that allows collectives and organizations to communicate areas of need and efficiently distribute tasks to their members. It comes with a beautiful, intuitive, and responsive interface that makes it easy to manage tasks.

It was developed with the needs of [Radtreff Campus Bonn e.V.](https://www.radtreffcampus.de/) in mind and is currently tightly coupled with [Rocket.Chat](https://rocket.chat/) as the authentication, notification, and communication provider. Over time, it is planned to support other authentication and communication methods.

> [!NOTE]
> This software is currently in alpha state. Parts of the software may not work as expected or change significantly. Portions of the software may still be tailored to the needs of the Radtreff Campus Bonn e.V. and may need to be adjusted for other organizations.

## Technology

Tendril Tasks is built with a vanilla [Ruby on Rails 8](https://rubyonrails.org/) stack, featuring quick, SPA-like interactions through the [Hotwire](https://hotwired.dev/) framework. It is styled with [Tailwind CSS](https://v3.tailwindcss.com/), leveraging the [Flowbite UI](https://flowbite.com/) library, implemented in [ViewComponents](https://viewcomponent.org/) and uses Stimulus for interactivity. The application is tested with RSpec and Capybara. Data is stored in an SQLite database, [which is plenty](https://youtu.be/wFUy120Fts8?si=759l-1K_5amTP_MV&t=729).

The application runs in a single Docker container and can be deployed easily with [Kamal](https://kamal-deploy.org/).

## Self-hosting

You can deploy Tendril Tasks with [Kamal](https://kamal-deploy.org/) or run it with Docker Compose. See [Self-hosting Tendril Tasks](.self-hosting/README.md) for instructions.

## Development

### Prerequisites

- [mise](https://mise.jdx.dev/) installs the pinned Ruby and Node.js versions from `mise.toml`.
- [libvips](https://www.libvips.org/) for image processing, e.g. `sudo apt install libvips` or `brew install vips`.
- Google Chrome for the system tests.

### Setup

```shell
git clone https://github.com/david-uhlig/tendril-tasks.git
cd tendril-tasks
mise install
bin/setup
```

`bin/setup` installs the dependencies, creates `.env` from `.env.sample`, creates and seeds the database, and starts the development server at http://localhost:3000. Run it again at any time to update your environment, add `--reset` to recreate the database, or `--skip-server` to skip starting the server. Afterward, start the server with `bin/dev`.

Rocket.Chat is optional in development. Sign in as any seeded user through the development sign in on the sign in page. The seeds include an admin, two editors, and seven users, along with sample initiatives, tasks, branding, footer links, and legal pages.

### Tests and Linters

```shell
mise run ci    # Security audits, linters and the full test suite, as on CI
mise run rff   # RSpec only, stops at the first failure
mise run test:rspec:optional  # Optional specs skipped by default, e.g. UI polish and third-party widgets
mise tasks     # List all tasks
```

### Sign in with a Local Rocket.Chat

To work on the Rocket.Chat login or notifications, run Rocket.Chat locally with Docker:

1. Start Rocket.Chat with the [official Docker Compose setup](https://github.com/RocketChat/rocketchat-compose). Rocket.Chat uses port 3000 by default, so expose it on another port, e.g. http://localhost:5000.
2. Complete the setup wizard. The first account you create is a Rocket.Chat admin. The first Rocket.Chat admin who signs in to Tendril Tasks becomes its admin.
3. Create a third-party login app as described in the [omniauth-rocketchat setup](https://github.com/david-uhlig/omniauth-rocketchat?tab=readme-ov-file#rocket-chat-setup) with the redirect URI `http://localhost:3000/users/auth/rocketchat/callback`.
4. Set `ROCKET_CHAT_HOST`, `ROCKET_CHAT_CLIENT_ID`, and `ROCKET_CHAT_CLIENT_SECRET` in your `.env` and restart the server.
5. Optional: To send notifications, create a personal access token in Rocket.Chat and set `ROCKET_CHAT_API_HOST`, `ROCKET_CHAT_API_USER_ID`, and `ROCKET_CHAT_API_AUTH_TOKEN`.

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0](http://semver.org/). Violations of this scheme should be reported as bugs.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/david-uhlig/tendril-tasks. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct][contributing].

## License

Tendril Tasks is released under the [O'Sassy License][LICENSE].
