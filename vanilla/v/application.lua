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
    local instance = {
        run = self.run,
        bootstrap = self.bootstrap,
        dispatcher = require('vanilla.v.dispatcher'):new(self)
    }
    setmetatable(instance, {__index = self})
    return instance
end

function Application:bootstrap()
    local bootstrap = require('application.bootstrap'):new(self.dispatcher)
    bootstrap:bootstrap()
    return self
end

function Application:run()
    local ok, status_or_error = pcall(function() return self.dispatcher:dispatch() end)
    if ok == false then
        self:error_response(status_or_error)
    end
end

function Application:error_response(err)
    local response = self.dispatcher:returnResponse()
    response.body = self.dispatcher:raise_error(err)
    response:response()
end

return Application