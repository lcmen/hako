# Redis

Hako runs Redis from the official `redis:<version>-alpine` image with Docker or Apple Container.

## Installed commands

The Redis install contains only:

```text
redis-server
redis-cli
```

`redis-server` controls the persistent server container:

- `redis-server start` creates and starts the container, then waits for Redis.
- `redis-server stop` stops and removes the container but keeps its data.
- `redis-server status` succeeds only when Redis is running and answers `PING`.
- `redis-server restart` stops and starts the container.
- `redis-server` with no arguments starts Redis and follows its logs.

`redis-cli` runs in a short-lived container connected to the managed server. `redis-cli --help` and `redis-cli --version` work without a running server.

## Versions and installation

Version discovery reads tags from the official Redis repository on Docker Hub. Hako exposes stable numeric Alpine aliases for Redis 6 and newer releases, including major, minor, and patch aliases. Release candidates, distro-pinned tags such as `8.0-alpine3.21`, non-Alpine tags, pre-6 releases, and tags missing the current host's `amd64` or `arm64` image are excluded.

Registry results are cached for 24 hours:

```text
${XDG_CACHE_HOME:-$HOME/.cache}/hako/redis.json
```

Set `CACHE=0` to bypass the cache. Installation pulls `redis:<version>-alpine`; wrapper execution never pulls an image.

The supported Redis range crosses license eras. Releases through 7.2.4 use BSD-3-Clause, Redis 7.4.x through 7.8.x use RSALv2 or SSPLv1, and Redis 8 and newer offer RSALv2, SSPLv1, or AGPLv3. Review the [official image license summary](https://hub.docker.com/_/redis) and [Redis licensing overview](https://redis.io/legal/licenses/) for the exact selected release.

## Environment and networking

When `HAKO_DOMAIN` is configured, activation exports:

```text
REDIS_URL=redis://<deterministic-container-hostname>:6379
```

Without `HAKO_DOMAIN`, Hako does not export `REDIS_URL`. Wrapper clients always connect internally over the shared `hako` runtime network: Docker uses the managed container name, while Apple Container uses its IPv4 address.

Hako does not publish a host port or configure host DNS. The server has no password and no TLS, so do not expose its container network to untrusted clients.

## Containers and persistence

The managed container name is:

```text
hako-redis-<version>-<instance>
```

Redis stores `/data` on the host at:

```text
${XDG_DATA_HOME:-$HOME/.local/share}/hako/redis/<version>/<instance>
```

Hako enables append-only persistence with `appendonly yes` and `appendfsync everysec`, following the official image's `/data` persistent-volume model. The container runs as the image's `redis` user, and Hako makes the version/instance data directory writable so bind mounts work with both runtimes. Up to roughly one second of acknowledged writes can be lost in a crash. Stopping Redis or uninstalling the mise tool does not delete this directory.

Docker uses `redis-cli ping` as the container healthcheck. Apple Container polls the same command inside the managed container.

## Current limits

- Images use tags and are not pinned by digest.
- Authentication, TLS, host-port publishing, Sentinel, clustering, modules, and custom configuration are not supported.
- Hako manages one Redis server per selected version and instance.
