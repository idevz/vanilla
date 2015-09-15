function pps( ... )
    local helpers = require 'vanilla.v.libs.utils'
    return helpers.pps(...)
end

function pp( ... )
    local helpers = require 'vanilla.v.libs.utils'
    -- helpers.pp(...)
    -- helpers.pp_to_file(..., '/Users/zj-git/vanilla/pretty/zj')
    local s = helpers.pps(...)
    -- local s = pps(...)
    print(s)
end

-- vanilla
local helpers = require 'vanilla.v.libs.utils'

-- perf
local pairs = pairs


local SysVaEnv = {}

SysVaEnv.defaults = {
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

function SysVaEnv.for_environment(env)
    -- load defaults
    local settings = SysVaEnv.defaults[env]
    if settings == nil then settings = SysVaEnv.defaults.other end

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

return SysVaEnv
