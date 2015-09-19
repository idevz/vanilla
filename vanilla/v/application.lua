-- vanilla
local Error = require 'vanilla.v.error'

-- perf
local pairs = pairs
local pcall = pcall
local require = require
local setmetatable = setmetatable
local function buildconf(config)
    local ok, sys_conf_or_error = pcall(function() return require('vanilla.sys.config') end)
    if ok then
        if config ~= nil then
            for k,v in pairs(config) do sys_conf_or_error[k] = v end
        end
    else
        sys_conf_or_error = config
    end
    ngx.app_name = sys_conf_or_error.name
    ngx.app_root = sys_conf_or_error.app.root
    return sys_conf_or_error
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
    ngx.say(pps(err))
    ngx.eof()
end

return Application