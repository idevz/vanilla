-- dep
local ansicolors = require 'ansicolors'

-- perf
local error = error
local sgmatch = string.gmatch

-- vanilla
local va_conf = require 'vanilla.sys.config'
local ngx_handle = require 'vanilla.sys.nginx.handle'
local helpers = require 'vanilla.v.libs.utils'

-- settings
local nginx_conf_source = 'config/nginx.conf'


local Vanilla = {}

-- convert true|false to on|off
local function convert_boolean_to_onoff(value)
    if value == true then value = 'on' else value = 'off' end
    return value
end

-- vanilla init
local function vanilla_init(nginx_content)
    -- vanilla init
    local vanilla_init = [[
lua_code_cache ]] .. convert_boolean_to_onoff(va_conf.settings.code_cache) .. [[;
    lua_package_path "./?.lua;./lib/?.lua;]] .. package.path .. [[;;";
    lua_package_cpath "./?.so;./lib/?.so;]] .. package.cpath .. [[;;";
]]

    return string.gsub(nginx_content, "{{GIN_INIT}}", vanilla_init)
end

-- vanilla runtime
local function vanilla_runtime(nginx_content)
    local vanilla_runtime = [[
location / {
            content_by_lua 'require(\"vanilla.core.router\").handler(ngx)';
        }
]]
    if va_conf.settings.expose_api_console == true then
        vanilla_runtime = vanilla_runtime .. [[
        location /vanillaconsole {
            content_by_lua 'require(\"vanilla.cli.api_console\").handler(ngx)';
        }
]]
    end

    local match = {}
    local tmp = 1
    for v in sgmatch(nginx_content , '{{(.-)}}') do
        match[tmp] = v
        tmp = tmp +1
    end

    pp(match)

    return string.gsub(nginx_content, "{{GIN_RUNTIME}}", vanilla_runtime)
end


function Vanilla.nginx_conf_content()
    -- read nginx.conf file
    local nginx_conf_template = helpers.read_file(nginx_conf_source)

    -- append notice
    nginx_conf_template = [[
# ===================================================================== #
# THIS FILE IS AUTO GENERATED. DO NOT MODIFY.                           #
# IF YOU CAN SEE IT, THERE PROBABLY IS A RUNNING SERVER REFERENCING IT. #
# ===================================================================== #

]] .. nginx_conf_template

    -- inject params in content
    local nginx_content = nginx_conf_template
    nginx_content = string.gsub(nginx_content, "{{GIN_PORT}}", va_conf.settings.port)
    nginx_content = string.gsub(nginx_content, "{{GIN_ENV}}", va_conf.env)

    -- vanilla imit & runtime
    nginx_content = vanilla_init(nginx_content)
    nginx_content = vanilla_runtime(nginx_content)

    -- return
    return nginx_content
end

function Vanilla.start(env)
    -- init base_launcher
    local ok, base_launcher = pcall(function() return ngx_handle.new(
        Vanilla.nginx_conf_content(),
        va_conf.app_dirs.tmp .. "/" .. va_conf.env .. "-nginx.conf"
    ) end)

    if ok == false then
        print(ansicolors("%{red}ERROR:%{reset} Cannot initialize launcher: " .. base_launcher))
        return
    end

    result = base_launcher:start(env)

    if result == 0 then
        if va_conf.env ~= 'test' then
            print(ansicolors("va_conf app in %{cyan}" .. va_conf.env .. "%{reset} was succesfully started on port " .. va_conf.settings.port .. "."))
        end
    else
        print(ansicolors("%{red}ERROR:%{reset} Could not start va_conf app on port " .. va_conf.settings.port .. " (is it running already?)."))
    end
end

function Vanilla.stop(env)
    -- init base_launcher
    local base_launcher = base_launcher()

    result = base_launcher:stop(env)

    if va_conf.env ~= 'test' then
        if result == 0 then
            print(ansicolors("va_conf app in %{cyan}" .. va_conf.env .. "%{reset} was succesfully stopped."))
        else
            print(ansicolors("%{red}ERROR:%{reset} Could not stop va_conf app (are you sure it is running?)."))
        end
    end
end

return Vanilla