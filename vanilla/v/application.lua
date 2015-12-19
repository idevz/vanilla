-- vanilla
local Error = require 'vanilla.v.error'
local sys_conf = require 'vanilla.sys.config'
local Dispatcher = require 'vanilla.v.dispatcher'
local Registry = require('vanilla.v.registry'):new('sys')
local Utils = require 'vanilla.v.libs.utils'

-- perf
local pairs = pairs
local pcall = pcall
local require = require
local setmetatable = setmetatable
local function buildconf(config)
    if config ~= nil then
        for k,v in pairs(config) do sys_conf[k] = v end
    end
    if sys_conf.name == nil or sys_conf.app.root == nil then
        Utils.raise_syserror([[
            Sys Err: Please set app name and app root in config/application.lua like:
            
                Appconf.name = 'idevz.org'
                Appconf.app.root='./'
            ]])
    end
    Registry['app_name'] = sys_conf.name
    Registry['app_root'] = sys_conf.app.root
    Registry['app_version'] = sys_conf.version
    return sys_conf
end

local function new_dispatcher(self)
    return Dispatcher:new(self)
end

local function new_bootstrap(lbootstrap, dispatcher)
    return require(lbootstrap):new(dispatcher)
end

local function run_bootstrap(bootstrap_instance)
    bootstrap_instance:bootstrap()
end

local function run_dispatcher(dispatcher_instance)
    dispatcher_instance:dispatch()
end

local Application = {}

function Application:lpcall( ... )
    local ok, rs_or_error = pcall( ... )
    if ok then
        return rs_or_error
    else
        self:raise_syserror(rs_or_error)
    end
end

function Application:new(config)
    self.config = buildconf(config)
    local instance = {
        run = self.run,
        bootstrap = self.bootstrap,
        dispatcher = self:lpcall(new_dispatcher, self)
    }
    setmetatable(instance, {__index = self})
    return instance
end

function Application:bootstrap()
    local lbootstrap = 'application.bootstrap'
    if self.config['bootstrap'] ~= nil then
        lbootstrap = self.config['bootstrap']
    end
    bootstrap = self:lpcall(new_bootstrap, lbootstrap, self.dispatcher)
    self:lpcall(run_bootstrap, bootstrap)
    return self
end

function Application:run()
    self:lpcall(run_dispatcher, self.dispatcher)
end

function Application:raise_syserror(err)
    if type(err) == 'table' then
        err = Error:new(err.code, err.msg)
    end
    ngx.say('<pre />')
    ngx.say(Utils.sprint_r(err))
    ngx.eof()
end

return Application