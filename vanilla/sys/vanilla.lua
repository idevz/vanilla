-- dep
local ansicolors = LoadV 'vanilla.v.libs.ansicolors'

-- perf
local error = error
local sgmatch = string.gmatch --cli didn't have ngx.re API

-- vanilla
local va_conf = LoadV 'vanilla.sys.config'
local ngx_handle = LoadV 'vanilla.sys.nginx.handle'
local ngx_config = LoadV 'vanilla.sys.nginx.config'
local helpers = LoadV 'vanilla.v.libs.utils'

-- settings
local nginx_conf_source = 'config/nginx.conf'

local Vanilla = {}

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

    local match = {}
    local tmp = 1
    for v in sgmatch(nginx_conf_template , '{{(.-)}}') do
        match[tmp] = v
        tmp = tmp +1
    end

    for _, directive in ipairs(match) do
        if ngx_config[directive] ~= nil then
            nginx_conf_template = string.gsub(nginx_conf_template, '{{' .. directive .. '}}', ngx_config[directive])
        else
            nginx_conf_template = string.gsub(nginx_conf_template, '{{' .. directive .. '}}', '#' .. directive)
        end
    end
    return nginx_conf_template
end

function base_launcher()
    return ngx_handle.new(
        Vanilla.nginx_conf_content(),
        va_conf.app_dirs.tmp .. "/" .. va_conf.env .. "-nginx.conf"
    )
end

function Vanilla.start(env)
    if env == nil then env = va_conf.env end
    -- init base_launcher
    local ok, base_launcher = pcall(function() return base_launcher() end)

    if ok == false then
        print(ansicolors("%{red}ERROR:%{reset} Cannot initialize launcher: " .. base_launcher))
        return
    end

    result = base_launcher:start(env)

    if result == 0 then
        if va_conf.env ~= 'test' then
            print(ansicolors("Vanilla app in %{green}" .. va_conf.env .. "%{reset} was succesfully started on port " .. ngx_config.PORT .. "."))
        end
    else
        print(ansicolors("%{red}ERROR:%{reset} Could not start Vanilla app on port " .. ngx_config.PORT .. " (is it running already?)."))
    end
end

function Vanilla.stop(env)
    if env == nil then env = va_conf.env end
    -- init base_launcher
    local base_launcher = base_launcher()

    result = base_launcher:stop(env)

    if va_conf.env ~= 'test' then
        if result == 0 then
            print(ansicolors("Vanilla app in %{green}" .. va_conf.env .. "%{reset} was succesfully stopped."))
        else
            print(ansicolors("%{red}ERROR:%{reset} Could not stop Vanilla app (are you sure it is running?)."))
        end
    end
end

function Vanilla.reload(env)
    if env == nil then env = va_conf.env end
    local base_launcher = base_launcher()
    
    result = base_launcher:reload(env)

    if va_conf.env ~= 'test' then
        if result == 0 then
            print(ansicolors("Vanilla app in %{green}" .. va_conf.env .. "%{reset} was succesfully reloaded."))
        else
            print(ansicolors("%{red}ERROR:%{reset} Could not reload Vanilla app (are you sure it is running?)."))
        end
    end
end


return Vanilla