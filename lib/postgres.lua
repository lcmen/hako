local M = {}

local utils = dofile(RUNTIME.pluginDirPath .. "/lib/utils.lua")

M.bins = {
    "createdb",
    "createuser",
    "dropdb",
    "dropuser",
    "pg_ctl",
    "pg_dump",
    "pg_restore",
    "postgres",
    "psql",
}
M.image_repository = "library/postgres"
M.image_tag_suffix = "-alpine"
M.image_tag_name_filter = "alpine"
M.minimum_major_version = 12
M.registry_cache_name = "postgres.json"
M.wrapper = "postgres"
M.version_tag_pattern = "^(%d+%.%d+)%-alpine$"

--- Builds the Docker image reference for a PostgreSQL version.
---@param version string PostgreSQL version selected by mise.
---@return string image Docker image reference.
function M.docker_image(version)
    return "postgres:" .. version .. M.image_tag_suffix
end

--- Returns PostgreSQL-specific environment variables for activation.
---@param ctx table Mise backend hook context.
---@param namespace string Explicit namespace.
---@return table[] env_vars List of mise env var entries.
function M.exec_env(ctx, namespace)
    local container = utils.container_name("postgres", ctx.version, namespace)
    local env_vars = {
        { key = "_HAKO_POSTGRES_IMAGE", value = M.docker_image(ctx.version) },
        { key = "_HAKO_POSTGRES_NAMESPACE", value = namespace },
        { key = "_HAKO_POSTGRES_VERSION", value = ctx.version },
        { key = "PGPASS", value = "postgres" },
        { key = "PGUSER", value = "postgres" },
    }

    local domain = os.getenv("HAKO_DOMAIN")
    if domain ~= nil and domain ~= "" then
        local host = container .. "." .. domain
        table.insert(env_vars, { key = "PGHOST", value = host })
    end

    return env_vars
end

--- Lists supported PostgreSQL versions from the configured registry source.
---@return string[] versions PostgreSQL versions available to mise.
function M.list_versions()
    local registry = dofile(RUNTIME.pluginDirPath .. "/lib/registry.lua")
    return registry.list_versions(
        M.image_repository,
        M.version_tag_pattern,
        M.image_tag_name_filter,
        M.minimum_major_version,
        M.registry_cache_name
    )
end

return M
