# Testing

Hako uses shell smoke tests for runtime behavior. The tests create a temporary mise install, then call the same command wrappers that users call.

## Requirements

Install the development tools:

```bash
mise install
```

Link the local plugin so mise can run its backend hooks:

```bash
mise plugin link hako /path/to/hako
```

Runtime tests need Docker, Apple Container, or both. The runtime service must be running. Tests explicitly set `HAKO_ADAPTER` for each adapter run, and missing test images are pulled before the test.
Hako does not auto-detect an adapter. Outside the test harness, changing the global setting requires stopping services through the old adapter and force-reinstalling tools after the change.

The smoke test skips a runtime that is not available. Both runtimes are needed for complete adapter coverage, but the script does not require both to exit successfully.

## Run checks

Run all configured static checks:

```bash
mise run check
```

Run the PostgreSQL smoke test:

```bash
tests/postgres.test.sh
```

Run the Redis smoke test:

```bash
tests/redis.test.sh
```

For a quick check of shell files:

```bash
bash -n wrappers/postgres wrappers/redis wrappers/lib/*.sh tests/*.sh
shellcheck wrappers/postgres wrappers/redis wrappers/lib/*.sh tests/*.sh
```

`mise run check` is the main command because it also checks Lua files.

## How the smoke test works

For each available adapter, `tests/postgres.test.sh`:

1. Creates a temporary install under `/tmp`.
2. Copies the wrapper files and supplies activation state through environment variables.
3. Creates the command symlinks used by the test.
4. Uses `tests/fixtures/postgres.json` to test version filtering without a registry request.
5. Starts PostgreSQL and checks its status.
6. Runs a query and a dump-and-restore round trip.
7. Stops and removes the managed container.

`tests/helpers.sh` provides setup, adapter, assertion, and command helpers. Each service setup exports its service-specific version, image, and isolation variables. `run` sets `HAKO_ADAPTER`, `MISE_PROJECT_ROOT`, `PATH`, and `XDG_DATA_HOME` for the temporary install.

The Redis smoke test uses the same adapter loop. It checks major, minor, and patch version discovery; command installation; startup and readiness; client help/version without a server; and key access.

## Write or extend a test

- Use one `tests/<service>.test.sh` file for each service.
- Enable `set -euo pipefail` in the test entry point.
- Resolve the repository root from `BASH_SOURCE` and source `tests/helpers.sh`.
- Keep test scenarios independent of the adapter when possible. Run the same scenario for both adapters.
- Test installed public commands through `run`. Do not call wrapper internals.
- Put stable input in `tests/fixtures/` and generated output in `tests/tmp/`.
- Use `assert` and `refute` for exact output lines. Use command exit status for lifecycle checks.
- Use `psql --set ON_ERROR_STOP=1` when an SQL error must fail the test.
- Register cleanup before starting a container. Cleanup must work after partial setup and must not hide the original failure.

Tests remove managed containers, but they keep database data in their temporary directories. Temporary `/tmp/hako-*-test.*` directories, cache directories, and `tests/tmp/dump.sql` may remain after a run. The shared `hako` network may also remain.
