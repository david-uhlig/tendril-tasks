# Self-hosting Tendril Tasks

Tendril Tasks runs in a single Docker container, built from the [`Dockerfile`](../Dockerfile) in the project root. You can deploy it with [Kamal](https://kamal-deploy.org/) (see [`config/deploy.yml.sample`](../config/deploy.yml.sample) and [`.kamal/secrets.sample`](../.kamal/secrets.sample)) or run it with Docker Compose as described below.

## Running with Docker Compose

From the project root, copy the sample configuration files:

```sh
cp .self-hosting/compose.yaml.sample compose.yaml
cp .env.sample .env.docker
```

In `.env.docker`, set at least `APP_BASE_URL`, `SECRET_KEY_BASE` (generate one with `openssl rand -hex 64`), `ROCKET_CHAT_HOST`, `ROCKET_CHAT_CLIENT_ID` and `ROCKET_CHAT_CLIENT_SECRET`. Sign-in works exclusively through Rocket.Chat, so you need a Rocket.Chat workspace with a [third-party login app](https://github.com/david-uhlig/omniauth-rocketchat?tab=readme-ov-file#rocket-chat-setup) whose redirect URI is `<APP_BASE_URL>/users/auth/rocketchat/callback`. Then start the app:

```sh
docker compose up --build
```

The app is now available at http://localhost:3000. The database is created on first start and persisted, together with uploaded files, in the `storage` volume.

The app expects HTTPS in production. It sends HSTS headers and only issues secure cookies, which browsers accept on `localhost`. On any other host, put the container behind a reverse proxy that terminates TLS.
