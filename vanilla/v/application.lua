-- perf
local pairs = pairs
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

function Application:new(ngx, config)
    self.ngx = ngx
    self.config = buildconf(config)
    local ok, dispatcher_or_error = pcall(function() return require('vanilla.v.dispatcher'):new(self) end)
    if ok then
        dispatcher = dispatcher_or_error
    else
        self:raise_syserror(dispatcher_or_error)
    end
    local instance = {
        run = self.run,
        bootstrap = self.bootstrap,
        dispatcher = dispatcher
    }
    setmetatable(instance, {__index = self})
    return instance
end

function Application:bootstrap()
    local ok, bootstrap_or_error = pcall(function() return require('application.bootstrap'):new(self.dispatcher) end)
    if ok then
        bootstrap = bootstrap_or_error
    else
        self:raise_syserror(bootstrap_or_error)
    end

    local ok, bootstarp_or_error = pcall(function() return bootstrap:bootstrap() end)
    if ok == false then
        self:raise_syserror(bootstarp_or_error)
    end
    
    return self
end

function Application:run()
    local ok, status_or_error = pcall(function() return self.dispatcher:dispatch() end)
    if ok == false then
        self:raise_syserror(status_or_error)
    end
end

function Application:raise_syserror(err)
    ngx.say(pps(err))
    ngx.eof()
end

return Application