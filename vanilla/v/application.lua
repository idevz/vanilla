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

local function new_dispatcher(self)
    return Dispatcher:new(self)
end

local function new_bootstrap_instance(lbootstrap, dispatcher)
    return require(lbootstrap):new(dispatcher)
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

function Application:buildconf(config)
    if config ~= nil then
        for k,v in pairs(config) do sys_conf[k] = v end
    end
    if sys_conf.name == nil or sys_conf.app.root == nil then
        self:raise_syserror([[
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

function Application:new(config)
    self.config = self:buildconf(config)
    local instance = {
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
    bootstrap_instance = self:lpcall(new_bootstrap_instance, lbootstrap, self.dispatcher)
    self:lpcall(bootstrap_instance.bootstrap, bootstrap_instance)
    return self
end

function Application:run()
    self:lpcall(self.dispatcher.dispatch, self.dispatcher)
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