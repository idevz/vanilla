-- perf
local pairs = pairs
local pcall = pcall
local require = require
local setmetatable = setmetatable
local function tappend(t, v) t[#t+1] = v end
local function buildconf(config)
    local sys_conf = require('vanilla.v.config')
    if config ~= nil then
        for k,v in pairs(config) do sys_conf[k] = v end
    end
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

function Application:new(ngx, config)
    self.ngx = ngx
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
    bootstrap = self:lpcall(function() return require('application.bootstrap'):new(self.dispatcher) end)
    self:lpcall(function() return bootstrap:bootstrap() end)
    
    return self
end

function Application:run()
    self:lpcall(function() return self.dispatcher:dispatch() end)
end

function Application:raise_syserror(err)
    ngx.say(pps(err))
    ngx.eof()
end

return Application