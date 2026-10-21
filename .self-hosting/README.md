# Self-hosting Tendril Tasks

Tendril Tasks runs in a single Docker container, built from the [`Dockerfile`](../Dockerfile) in the project root. You can deploy it with [Kamal](https://kamal-deploy.org/) (see [`config/deploy.yml.sample`](../config/deploy.yml.sample) and [`.kamal/secrets.sample`](../.kamal/secrets.sample)) or run it with Docker Compose as described below.

## Running with Docker Compose

From the project root, copy the sample configuration files:

```sh
cp .self-hosting/compose.yaml.sample compose.yaml
cp .env.sample .env.docker
```

In `.env.docker`, uncomment and set at least `APP_BASE_URL`, `SECRET_KEY_BASE` (generate one with `openssl rand -hex 64`), `ROCKET_CHAT_HOST`, `ROCKET_CHAT_CLIENT_ID` and `ROCKET_CHAT_CLIENT_SECRET`. Sign-in works exclusively through Rocket.Chat, so you need a Rocket.Chat workspace with a [third-party login app](https://github.com/david-uhlig/omniauth-rocketchat?tab=readme-ov-file#rocket-chat-setup) whose redirect URI is `<APP_BASE_URL>/users/auth/rocketchat/callback`. Then start the app:

```sh
docker compose up --build
```

The app is now available at http://localhost:3000. The database is created on first start and persisted, together with uploaded files, in the `storage` volume.

The container reports as healthy in `docker compose ps` once the app answers on `/up`. Both sample configurations define this health check for the web server only. If you run background jobs in a separate container with `bin/jobs`, don't add the health check there, because that container never answers on `/up`.

The app expects HTTPS in production. It sends HSTS headers and only issues secure cookies, which browsers accept on `localhost`. On any other host, put the container behind a reverse proxy that terminates TLS.

## Backup and restore

All data lives in the storage volume, mounted at `/rails/storage`:

- `production.sqlite3`: the database, with users, initiatives, tasks and settings.
- `uploads/`: uploaded files, like the logo, pictures in descriptions and profile photos.
- `production_cache.sqlite3`, `production_queue.sqlite3` and `production_cable.sqlite3`: the cache, background jobs and live updates. They don't need a backup and are recreated on start.

Also keep a copy of your configuration, `.env.docker` or `.kamal/secrets` and `config/deploy.yml`, somewhere safe. They aren't part of the backup.

### Creating a backup

Don't copy the database file while the app runs. Changes still in its write-ahead log would be missing, and the copy may be corrupt. Instead, `bin/backup` takes a consistent snapshot of the database with SQLite's online backup, checks its integrity and writes it, together with the uploaded files, to a gzipped tar archive. It runs inside the app's container, while the app keeps running, and writes the archive to stdout, so you can store it outside the server. With `--uncompressed`, it writes a plain tar archive instead, e.g. to pipe it into a backup tool like restic or borg that compresses and deduplicates on its own.

With Docker Compose, from the project root:

```sh
docker compose exec -T web bin/backup > tendril-tasks-$(date +%F_%H-%M-%S).tar.gz
```

With Kamal, from your machine, replacing `tendril-tasks` if you changed the `service` in `config/deploy.yml`:

```sh
ssh root@192.168.0.1 'docker exec $(docker ps -q --latest -f label=service=tendril-tasks -f label=role=web) bin/backup' \
  > tendril-tasks-$(date +%F_%H-%M-%S).tar.gz
```

Or on the server Kamal deployed to:

```sh
docker exec $(docker ps -q --latest -f label=service=tendril-tasks -f label=role=web) bin/backup \
  > /var/backups/tendril-tasks-$(date +%F_%H-%M-%S).tar.gz
```

To back up every night, run the command from a cron job, e.g. `30 3 * * *`, and keep a few older archives, too. In a crontab, write `%` as `\%`. Archives stored on the server itself are lost together with it, so copy them elsewhere, too. A backup you haven't restored once is a hope rather than a backup, so try the restore below on a spare machine.

Each archive contains a `backup-info.txt` with the time it was created, in UTC, the app version and the version of the database schema it was created with, and a link to the restore instructions below:

```sh
tar -xOf tendril-tasks-2026-10-19_03-30-00.tar.gz backup-info.txt
```

### Restoring a backup

Restore a backup with the app version it was created with or a newer one. When the app starts, it migrates the restored database to its own version, so you can restore an older backup after upgrading. It can't go back the other way: an older version doesn't work with a database from a newer one. If the release notes of a version you skip require an upgrade stop, e.g. "0.9.0 requires 0.8.x first", restore the backup with that version first, start it once, then upgrade.

Restoring replaces all data with the backup's. Changes made since the backup are lost, so create a backup of the current state first.

The restore stops the app and replaces the database and the uploaded files in the storage volume. It also deletes the database's write-ahead log, which would otherwise corrupt the restored database, and the cache, queue and cable databases, which are recreated on start. Background jobs that were queued but not yet done are lost. The commands restore gzipped and uncompressed archives alike.

With Docker Compose, from the project root:

```sh
docker compose stop web
docker compose run --rm --no-deps -T --entrypoint bash web \
  -c 'cd storage && rm -rf production*.sqlite3* uploads && gzip -dcf | tar -xf - --exclude=backup-info.txt' \
  < tendril-tasks-2026-10-19_03-30-00.tar.gz
docker compose start web
```

With Kamal, from your machine, replacing `your-user/tendril-tasks` with your `image` and `tendril-tasks_storage` with your volume from `config/deploy.yml`:

```sh
bin/kamal app stop
ssh root@192.168.0.1 'docker run --rm -i -v tendril-tasks_storage:/rails/storage --entrypoint bash your-user/tendril-tasks:latest \
  -c "cd storage && rm -rf production*.sqlite3* uploads && gzip -dcf | tar -xf - --exclude=backup-info.txt"' \
  < tendril-tasks-2026-10-19_03-30-00.tar.gz
bin/kamal app start
```

Or on the server Kamal deployed to, with the same replacements. It stops all containers of the app, including those running background jobs with `bin/jobs`, and starts them again afterwards:

```sh
containers=$(docker ps -q -f label=service=tendril-tasks)
docker stop $containers
docker run --rm -i -v tendril-tasks_storage:/rails/storage --entrypoint bash your-user/tendril-tasks:latest \
  -c 'cd storage && rm -rf production*.sqlite3* uploads && gzip -dcf | tar -xf - --exclude=backup-info.txt' \
  < /var/backups/tendril-tasks-2026-10-19_03-30-00.tar.gz
docker start $containers
```

Migrations run before the app answers on `/up`. If the backup is several versions old, starting may take longer than usual.
