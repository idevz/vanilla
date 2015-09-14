-- gin
local helpers = require 'vanilla.v.libs.utils'

-- perf
local pairs = pairs


local SVaEnv = {}

SVaEnv.defaults = {
    development = {
        code_cache = false,
        port = 7200,
        expose_api_console = true
    },

    test = {
        code_cache = true,
        port = 7201,
        expose_api_console = false
    },

    production = {
        code_cache = true,
        port = 80,
        expose_api_console = false
    },

    other = {
        code_cache = true,
        port = 80,
        expose_api_console = false
    }
}

function SVaEnv.for_environment(env)
    -- load defaults
    local settings = SVaEnv.defaults[env]
    if settings == nil then settings = SVaEnv.defaults.other end

    -- override defaults from app settings
    local app_settings = helpers.try_require('config.settings', {})

    if app_settings ~= nil then
        local app_settings_env = app_settings[env]
        if app_settings_env ~= nil then
            for k, v in pairs(app_settings_env) do
                settings[k] = v
            end
        end
    end

    return settings
end

return SVaEnv
