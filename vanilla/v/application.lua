-- vanilla
local Error = require 'vanilla.v.error'
local sys_conf = require 'vanilla.sys.config'
local Registry = require('vanilla.v.registry'):new('sys')

-- perf
local pairs = pairs
local pcall = pcall
local require = require
local setmetatable = setmetatable
local function buildconf(config)
    if config ~= nil then
        for k,v in pairs(config) do sys_conf[k] = v end
    end
    Registry:set('app_name', sys_conf.name)
    Registry:set('app_root', sys_conf.app.root)
    Registry:set('app_version', sys_conf.version)
    return sys_conf
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
        dispatcher = self:lpcall(function() return require('vanilla.v.dispatcher'):new(self) end)
    }
    setmetatable(instance, {__index = self})
    return instance
end

function Application:bootstrap()
    -- ngx.dispatcher = self.dispatcher
    local lbootstrap = 'application.bootstrap'
    if self.config['bootstrap'] ~= nil then
        lbootstrap = self.config['bootstrap']
    end
    bootstrap = self:lpcall(function() return require(lbootstrap):new(self.dispatcher) end)
    self:lpcall(function() bootstrap:bootstrap() end)
    
    return self
end

function Application:run()
    self:lpcall(function() return self.dispatcher:dispatch() end)
end

function Application:raise_syserror(err)
    if type(err) == 'table' then
        err = Error:new(err.code, err.msg)
    end
    ngx.say('<pre />')
    ngx.say(sprint_r(err))
    ngx.eof()
end

return Application