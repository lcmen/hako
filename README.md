# hako

`hako` is a [mise](https://mise.jdx.dev/) backend plugin that provides a local database engine through containers.

Install the plugin as `hako`, add a database to `mise.toml`, then start, stop, and use the database with familiar binaries such as `pg_ctl`, `postgres`, `psql`, `pg_dump`, and `pg_restore`. Those binaries are wrappers around a versioned PostgreSQL OCI image, so they feel like native tools while the database engine runs in a managed container.

Current status: PostgreSQL on Docker and Apple Container.

## Requirements

- [mise](https://mise.jdx.dev/)
- One usable runtime: Docker with a running daemon, or Apple Container with a running service
- Apple Container requires Apple silicon and macOS 26 or later
- Network access during `mise install` so the selected runtime can pull the PostgreSQL image

## Install The Plugin

```bash
mise plugin install hako https://github.com/lcmen/hako
```

For local development of this plugin:

```bash
mise plugin link hako /path/to/hako
```

## Add database

Add PostgreSQL to `mise.toml`:

```bash
mise use hako:postgres@18.4
```

During install, `hako` pulls:

```text
postgres:18.4-alpine
```

and installs wrapper commands into the mise tool installation. The selected runtime adapter is recorded in that installation.

Version discovery is cached for 24 hours in:

```text
${XDG_CACHE_HOME:-$HOME/.cache}/hako/postgres.json
```

Set `CACHE=0` to bypass the registry cache for a single run.

Set `DEBUG=1` to print detailed hako diagnostics for a single command:

```bash
DEBUG=1 mise ls-remote hako:postgres
```

Debug output includes cache decisions, individual Docker Hub tag pages, adapter selection, image installation, and container lifecycle operations. Hako-owned messages use the `[hako]` prefix. Interactive debug messages are cyan, warnings are orange, and errors are red; redirected output does not contain terminal color codes.

## Use database

Thanks to thin wrappers, all commands can be executed like native ones:

```bash
pg_ctl start
psql
pg_ctl stop
```

## Container Runtime

During `mise install`, hako prefers a usable Apple Container service, then a usable Docker daemon. Set `HAKO_ADAPTER` in mise config before installing to choose explicitly:

```toml
# ~/.config/mise/config.toml
[env]
HAKO_ADAPTER = "apple"
# HAKO_ADAPTER = "docker"
```

Apple Container must be installed and started first:

```bash
container system start
```

Changing `HAKO_ADAPTER` after installation is rejected so wrappers never mix runtimes. Force-reinstall with the intended adapter instead:

```bash
mise install --force hako:postgres@18.4
```

## Isolation

By default, database runs in global mode which gives you one database container instance for the selected version. Use `isolated = true` to create a project-specific instance, i.e.:

```bash
mise use 'hako:postgres@18.4[isolated=true]'
```

This lets different projects use the same PostgreSQL version without sharing the same container or data directory.

## Hostnames For Applications

By default, wrappers connect through the selected runtime's shared `hako` network and no database container host is exposed to applications.

To expose stable container hostnames with Apple Container, create a local DNS domain and configure the same TLD in mise:

```bash
sudo container system dns create container
```

```toml
# ~/.config/mise/config.toml
[env]
HAKO_DOMAIN = "container"
```

Apple Container resolves named containers as `<container-name>.<domain>`. `hako` creates the persistent container with a deterministic name, so when `HAKO_DOMAIN` is available to mise, activation exports the database host using the tool's environment convention:

```text
PGHOST=hako-postgres-18-4-myapp-0abc.container
```

Rails can then use the activated environment:

```yaml
development:
  adapter: postgresql
  host: <%= ENV.fetch("PGHOST") %>
  username: <%= ENV.fetch("PGUSER", "postgres") %>
  password: <%= ENV.fetch("PGPASS", "postgres") %>
```

DNS must resolve the generated hostname to an address reachable from the host. Apple Container's DNS domain is managed with `container system dns`; Docker users need a DNS service such as [`devdns`](https://github.com/lcmen/devdns), and Docker Desktop for macOS may need additional networking support for direct container IP access.

## Data Storage

Database files are stored outside the mise install directory:

```text
${XDG_DATA_HOME:-$HOME/.local/share}/hako/postgres/<version>/<instance>
```

Stopping PostgreSQL removes the container but keeps the data directory.

Uninstalling the mise tool does not delete database data.

## Runtime Details

Each runtime uses one shared network in its own runtime namespace:

```text
hako
```

`pg_ctl start` creates a persistent container and waits until PostgreSQL is ready before returning. Docker uses a container healthcheck; Apple Container polls `pg_isready` inside the managed container.

Client commands run in short-lived containers on the shared network. Docker clients connect to the managed container by name; Apple Container clients connect to its IPv4 address on that network.

If the selected runtime removes the image later, wrappers fail with a clear message. Run `mise install --force hako:postgres@18.4` to pull the image back.

## Current Limitations

- PostgreSQL is the only implemented database.
- MySQL and Valkey are planned but not available yet.
- Automatic host DNS setup is not implemented yet.
- Images are pulled by tag, not pinned by digest yet.
