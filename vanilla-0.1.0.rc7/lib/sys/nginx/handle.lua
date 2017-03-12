local va_conf = LoadV 'vanilla.sys.config'

local function create_dirs(necessary_dirs)
    for _, dir in pairs(necessary_dirs) do
        os.execute("mkdir -p " .. dir .. " > /dev/null")
    end
end

local function create_nginx_conf(nginx_conf_file_path, nginx_conf_content)
    local fw = io.open(nginx_conf_file_path, "w")
    fw:write(nginx_conf_content)
    fw:close()
end

local function remove_nginx_conf(nginx_conf_file_path)
    os.remove(nginx_conf_file_path)
end

local function nginx_command(env, nginx_conf_file_path, nginx_signal)
    local devnull_logs = ""
    if V_TRACE == false then devnull_logs = " 2>/dev/null" end

    local env_cmd = ""
    local nginx = ""
    if VANILLA_NGX_PATH ~= nil then
        nginx = VANILLA_NGX_PATH .. "/sbin/nginx "
    else
        nginx = "nginx "
    end
    if env ~= nil then env_cmd = "-g \"env VA_ENV=" .. env .. ";\"" end
    local cmd = nginx .. nginx_signal .. " " .. env_cmd .. " -p `pwd`/ -c " .. nginx_conf_file_path .. devnull_logs

    if V_TRACE == true then
        print(cmd)
    end

    return os.execute(cmd)
end

local function start_nginx(env, nginx_conf_file_path)
    return nginx_command(env, nginx_conf_file_path, '')
end

local function stop_nginx(env, nginx_conf_file_path)
    return nginx_command(env, nginx_conf_file_path, '-s stop')
end

local function reload_nginx(env, nginx_conf_file_path)
    return nginx_command(env, nginx_conf_file_path, '-s reload')
end


local NginxHandle = {}
NginxHandle.__index = NginxHandle

function NginxHandle.new(nginx_conf_content, nginx_conf_file_path)
    local necessary_dirs = va_conf.app_dirs

    local instance = {
        nginx_conf_content = nginx_conf_content,
        nginx_conf_file_path = nginx_conf_file_path,
        necessary_dirs = necessary_dirs
    }
    setmetatable(instance, NginxHandle)
    return instance
end

function NginxHandle:start(env)
    create_dirs(self.necessary_dirs)
    create_nginx_conf(self.nginx_conf_file_path, self.nginx_conf_content)

    return start_nginx(env, self.nginx_conf_file_path)
end

function NginxHandle:stop(env)
    result = stop_nginx(env, self.nginx_conf_file_path)
    remove_nginx_conf(self.nginx_conf_file_path)

    return result
end

function NginxHandle:reload(env)
    remove_nginx_conf(self.nginx_conf_file_path)
    create_dirs(self.necessary_dirs)
    create_nginx_conf(self.nginx_conf_file_path, self.nginx_conf_content)

    return reload_nginx(env, self.nginx_conf_file_path)
end


return NginxHandle