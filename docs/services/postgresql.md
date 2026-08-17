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

Version discovery reads PostgreSQL tags from Docker Hub. Hako exposes concrete Alpine releases such as `18.3` and `18.4`, but excludes the mutable `18` major-only tag. It supports PostgreSQL 12 and newer and filters images for the current `amd64` or `arm64` host.

Use a major selector such as `hako:postgres@18`. Mise resolves it to the newest matching concrete release. Run `CACHE=0 mise upgrade` to discover and install a newer release immediately.

Registry results are cached for 24 hours:

```text
${XDG_CACHE_HOME:-$HOME/.cache}/hako/postgres.json
```

Set `CACHE=0` to bypass the cache.

Installation pulls:

```text
postgres:<resolved-version>-alpine
```

Wrappers do not pull the image later. If it is missing, force a mise install to pull it again.

Installation and execution require the same global `HAKO_ADAPTER` value (`apple` or `docker`). Hako does not auto-detect a runtime.
To change adapters, stop PostgreSQL through the old adapter, update the global setting, force-reinstall the tool, and then start it through the new adapter. Otherwise, its old container can remain in the previous runtime.

## Environment

Activation adds the installed commands to `PATH` and sets:

```text
_HAKO_POSTGRES_VERSION=<resolved-version>
_HAKO_POSTGRES_IMAGE=postgres:<resolved-version>-alpine
_HAKO_POSTGRES_ISOLATED=<true-or-false>
PGUSER=postgres
PGPASS=postgres
```

These underscore-prefixed values are internal wrapper state. The wrapper requires this activation state, so run PostgreSQL commands in an activated mise environment. No installation manifest is used.

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
