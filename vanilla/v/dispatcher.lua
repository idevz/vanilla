-- dep
local json = require 'cjson'

-- vanilla
local Controller = require 'vanilla.v.controller'
local Request = require 'vanilla.v.request'
local Response = require 'vanilla.v.response'
local Error = require 'vanilla.v.error'

-- app
-- local Routes = require 'config.routes'
-- local Application = require 'config.application'

-- perf
local error = error
local pairs = pairs
local pcall = pcall
local require = require
local setmetatable = setmetatable

local Dispatcher = {}
Dispatcher.__index = Dispatcher

function Dispatcher:new(application)
    local instance = {
        application = application,
        dispatch = self.dispatch
    }
    setmetatable(instance, Dispatcher)
    return instance
end

function Dispatcher:setRequest(request)
	self.request = request
end

function Dispatcher:dispatch()

end

function Dispatcher:setView()
end

function Dispatcher:getApplication()
	return self.application
end

function Dispatcher:getRequest()
    local ok, request_or_error = pcall(function() return Request:new(self.application.ngx) end)
    if ok == false then
        -- parsing errors
        local err = Error.new(request_or_error.code, request_or_error.custom_attrs)
        response = Response.new({ status = err.status, body = err.body })
        Router.respond(ngx, response)
        return false
    end
    return request_or_error
end

function Dispatcher:getRouter()
end

function Dispatcher:initView()
end

function Dispatcher:registerPlugin()
end

function Dispatcher:returnResponse()
end

function Dispatcher:setDefaultAction()
end

function Dispatcher:setDefaultController()
end

function Dispatcher:setDefaultModule()
end

function Dispatcher:setErrorHandler()
end

function Dispatcher:autoRender()
end

function Dispatcher:disableView()
end

function Dispatcher:enableView()
end

return Dispatcher