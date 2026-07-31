local M = {}

local utils = dofile(RUNTIME.pluginDirPath .. "/lib/utils.lua")

M.bins = {
    "redis-cli",
    "redis-server",
}
M.image_repository = "library/redis"
M.image_tag_suffix = "-alpine"
M.image_tag_name_filter = "alpine"
M.minimum_major_version = 6
M.registry_cache_name = "redis.json"
M.wrapper = "redis"
M.version_tag_pattern = "^(%d+%.?%d*%.?%d*)%-alpine$"

--- Builds the Docker image reference for a Redis version.
---@param version string Redis version selected by mise.
---@return string image Docker image reference.
function M.docker_image(version)
    return "redis:" .. version .. M.image_tag_suffix
end

--- Returns Redis-specific environment variables for activation.
---@param ctx table Mise backend hook context.
---@return table[] env_vars List of mise env var entries.
function M.exec_env(ctx)
    local domain = os.getenv("HAKO_DOMAIN")
    if domain == nil or domain == "" then
        return {}
    end

    local isolated = utils.boolean_option(ctx, "isolated", false)
    local container = utils.container_name("redis", ctx.version, isolated)
    return {
        { key = "REDIS_URL", value = "redis://" .. container .. "." .. domain .. ":6379" },
    }
end

--- Lists supported Redis versions from the configured registry source.
---@return string[] versions Redis versions available to mise.
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
