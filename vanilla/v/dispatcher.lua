-- dep
local json = require 'cjson'

-- vanilla
-- local Controller = require 'vanilla.v.controller'
-- local Request = require 'vanilla.v.request'
-- local Response = require 'vanilla.v.response'
-- local Error = require 'vanilla.v.error'

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

function Dispatcher:new(application)
    local instance = {
        application = application,
        route = 'zj',
        dispatch = self.dispatch
    }
    setmetatable(instance, {__index = self})
    return instance
end

function Dispatcher:getRequest()
	return 'ok'
    -- local ok, request_or_error = pcall(function() return Request:new(self.application.ngx) end)
    -- if ok == false then
    --     -- parsing errors
    --     local err = Error.new(request_or_error.code, request_or_error.custom_attrs)
    --     response = Response.new({ status = err.status, body = err.body })
    --     Router.respond(ngx, response)
    --     return false
    -- end
    -- return request_or_error
end

function Dispatcher:setRequest(request)
	self.request = request
end

function Dispatcher:dispatch()
	ngx.say('=========')
	ngx.eof()
    -- create request object
    -- local request = self.getRequest()
    -- if request == false then return end

    -- -- get routes
    -- local ok, controller_name_or_error, action, params, request = pcall(function() return self.route.match() end)

    -- local response

    -- if ok == false then
    --     -- match returned an error (for instance a 412 for no header match)
    --     local err = Error.new(controller_name_or_error.code, controller_name_or_error.custom_attrs)
    --     response = Response.new({ status = err.status, body = err.body })
    --     Router.respond(ngx, response)

    -- elseif controller_name_or_error then
    --     -- matching routes found
    --     response = self.call_controller(request, controller_name_or_error, action, params)
    --     Router.respond(ngx, response)

    -- else
    --     -- no matching routes found
    --     ngx.exit(ngx.HTTP_NOT_FOUND)
    -- end
end

function Dispatcher:call_controller(request, controller_name, action, params)
	ngx.say(controller_name)
    -- load matched controller and set metatable to new instance of controller
    -- local matched_controller = require(controller_name)
    -- local controller_instance = Controller.new(request, params)
    -- setmetatable(matched_controller, { __index = controller_instance })

    -- -- call action
    -- local ok, status_or_error, body, headers = pcall(function() return matched_controller[action](matched_controller) end)

    -- local response

    -- if ok then
    --     -- successful
    --     response = Response.new({ status = status_or_error, headers = headers, body = body })
    -- else
    --     -- controller raised an error
    --     local ok, err = pcall(function() return Error.new(status_or_error.code, status_or_error.custom_attrs) end)

    --     if ok then
    --         -- API error
    --         response = Response.new({ status = err.status, headers = err.headers, body = err.body })
    --     else
    --         -- another error, throw
    --         error(status_or_error)
    --     end
    -- end

    -- return response
end

function Dispatcher:setView()
end

function Dispatcher:getApplication()
	return self.application
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