# PostgreSQL

PostgreSQL is the first service implemented by Hako. It runs `postgres:<version>-alpine` with Docker or Apple Container.

## Installed commands

One wrapper provides these command names:

```text
postgres
pg_ctl
psql
pg_dump
pg_restore
createdb
dropdb
createuser
dropuser
```

`pg_ctl` controls the persistent server container:

- `pg_ctl start` creates and starts the container, then waits for PostgreSQL.
- `pg_ctl stop` stops and removes the container but keeps its data.
- `pg_ctl status` succeeds only when PostgreSQL is running and ready.
- `pg_ctl restart` stops and starts the container.
- `pg_ctl reload` reloads the PostgreSQL configuration.

`postgres` starts the server and follows its logs. Client commands run in short-lived containers. They do not start the server automatically.

## Versions and installation

Version discovery reads PostgreSQL tags from Docker Hub. Hako accepts exact Alpine tags such as `18-alpine` and `18.4-alpine`, then exposes them as versions `18` and `18.4`. It supports PostgreSQL 12 and newer and filters images for the current `amd64` or `arm64` host.

Registry results are cached for 24 hours:

```text
${XDG_CACHE_HOME:-$HOME/.cache}/hako/postgres.json
```

Set `HAKO_CACHE=0` to bypass the cache.

Installation pulls:

```text
postgres:<version>-alpine
```

Wrappers do not pull the image later. If it is missing, force a mise install to pull it again.

## Environment

Activation adds the installed commands to `PATH` and sets:

```text
PGUSER=postgres
PGPASS=postgres
```

When `HAKO_DOMAIN` is set, activation also sets `PGHOST` to the deterministic container hostname. Hako does not configure host DNS.

## Containers and data

The server uses the shared `hako` network. Its name is:

```text
hako-postgres-<version>-<instance>
```

Global installs use the `global` instance. Isolated installs derive an instance from the project root.

PostgreSQL data is stored on the host:

```text
${XDG_DATA_HOME:-$HOME/.local/share}/hako/postgres/<version>/<instance>
```

Stopping the server or uninstalling the mise tool does not remove this data.

Docker clients connect by container name. Apple Container clients connect to the server container's IPv4 address. Docker waits for its container healthcheck; Apple Container polls `pg_isready`.

## Current limits

- Images use tags and are not pinned by digest.
- Hako does not create application databases or run migrations.
- Hako does not allocate host ports.
- Host DNS setup is external to Hako.
