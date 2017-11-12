-- perf
local pairs = pairs
local pcall = pcall
local setmetatable = setmetatable

-- vanilla
local Error = LoadV 'vanilla.v.error'
local Dispatcher = LoadV 'vanilla.v.dispatcher'
-- local Registry = LoadV('vanilla.v.registry'):new('sys')
local Utils = LoadV 'vanilla.v.libs.utils'
local Bootstrap = LoadV 'vanilla.v.bootstrap'

local function new_dispatcher(self)
    return Dispatcher:new(self)
end

local Application = {}

function Application:lpcall( ... )
    local ok, rs_or_error = pcall( ... )
    if ok then return rs_or_error else self:raise_syserror(rs_or_error) end
end

function Application:buildconf(config)
    local sys_conf = config
    sys_conf['version'] = config['vanilla_version'] or 'idevz-vanilla'
    if sys_conf.name == nil or sys_conf.app.root == nil then
        self:raise_syserror([[
            Sys Err: Please set app name and app root in config/application.lua like:
            
                Appconf.name = 'idevz.org'
                Appconf.app.root='/data1/VANILLA_ROOT/idevz.org/'
            ]])
    end
    -- Registry['app_name'] = sys_conf.name
    -- Registry['app_root'] = sys_conf.app.root
    -- Registry['app_version'] = sys_conf.version
    self.config = sys_conf
    return true
end

function Application:new(ngx, config)
    self:buildconf(config)
    local instance = { dispatcher = self:lpcall(new_dispatcher, self) }
    setmetatable(instance, {__index = self})
    return instance
end

function Application:bootstrap(lboots)
    local bootstrap_instance = Bootstrap:new(lboots(self.dispatcher))
    self:lpcall(bootstrap_instance.bootstrap, bootstrap_instance)
    return self
end

function Application:run()
    self:lpcall(self.dispatcher.dispatch, self.dispatcher)
end

function Application:raise_syserror(err)
    if type(err) == 'table' then
        err = Error:new(err.code, err.msg)
        ngx.status = err.status
    else
        ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    end
    ngx.say('<pre />')
    ngx.say(Utils.sprint_r(err))
    ngx.exit(ngx.HTTP_INTERNAL_SERVER_ERROR)
end

return Application
