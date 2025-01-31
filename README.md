[license]: LICENSE.md
[contributing]: CODE_OF_CONDUCT.md

# <img src="app/assets/images/brand/logo.svg" height="28"> Tendril Tasks

_Together, individual efforts intertwine, sparking growth that allows the entire collective to flourish._

## About

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)][license]
[![Contributor Covenant](https://img.shields.io/badge/Contributor%20Covenant-2.1-4baaaa.svg)][contributing]

Tendril Tasks is a task distribution application that allows collectives and organizations to communicate areas of need and efficiently distribute tasks to their members. It comes with a beautiful, intuitive and responsive interface that makes it easy to manage tasks.

It was developed with the needs of [Radtreff Campus Bonn e.V.](https://www.radtreffcampus.de/) in mind and is currently tightly coupled with [Rocket.Chat](https://rocket.chat/) as the authentication, notification and communication provider. Over time, it is planned to support other authentication and communication methods.

> [!NOTE]
> This software is currently in alpha state. Parts of the software may not work as expected or change significantly. Portions of the software may still be tailored to the needs of the Radtreff Campus Bonn e.V. and may need to be adjusted for other organizations.

## Technology

Tendril Tasks is built with a vanilla [Ruby on Rails 8](https://rubyonrails.org/) stack, featuring quick, SPA-like interactions through the [Hotwire](https://hotwired.dev/) framework. It is styled with [Tailwind CSS](https://v3.tailwindcss.com/), leveraging the [Flowbite UI](https://flowbite.com/) library, implemented in [ViewComponents](https://viewcomponent.org/) and uses Stimulus for interactivity. The application is tested with RSpec and Capybara. Data is stored in a SQLite database, [which is plenty](https://youtu.be/wFUy120Fts8?si=759l-1K_5amTP_MV&t=729).

The application runs in a single Docker container and can be deployed easily with [Kamal](https://kamal-deploy.org/).

## Versioning

This library aims to adhere to [Semantic Versioning 2.0.0](http://semver.org/). Violations of this scheme should be reported as bugs.

## Contributing

This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

Bug reports and pull requests are welcome on the [GitHub project page](https://github.com/david-uhlig/tendril-tasks).

## License

Tendril Tasks is release under the MIT License. See [LICENSE] for details.
