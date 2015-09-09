-- dep
local json = require 'cjson'

-- vanilla
local Controller = require 'vanilla.v.controller'
local Request = require 'vanilla.v.request'
local Response = require 'vanilla.v.response'
local View = require 'vanilla.v.views.rtpl'
local Error = require 'vanilla.v.error'

-- perf
local error = error
local pairs = pairs
local pcall = pcall
local require = require
local setmetatable = setmetatable

local Dispatcher = {}

function Dispatcher:new(application)
	self:init(application)
    local instance = {
        application = application,
        router = require('vanilla.v.routes.simple'):new(self.request),
        dispatch = self.dispatch
    }
    setmetatable(instance, {__index = self})
    return instance
end

function Dispatcher:init(application)
	local req_ok, request_or_error = pcall(function() return Request:new(application.ngx) end)
	if req_ok == false then
		ngx.say('------Request:new Err' .. request_or_error)
	end
	self.request = request_or_error
	local resp_ok, response_or_error = pcall(function() return Response:new(application.ngx) end)
	if resp_ok == false then
		ngx.say('------Response:new Err' .. response_or_error)
	end
	self.response = response_or_error
end

function Dispatcher:getRequest()
	return self.request
end

function Dispatcher:setRequest(request)
	self.request = request
end

function Dispatcher:dispatch()
	local ok, controller_name_or_error, action= pcall(function() return self.router:match() end)

    local response

    if ok and controller_name_or_error then
        -- matching routes found
    	response = self:call_controller(controller_name_or_error, action)
        response:response()
    else
        -- no matching routes found
        ngx.exit(self.application.ngx.HTTP_NOT_FOUND)
    end
end

function Dispatcher:call_controller(controller_name, action)
    -- load matched controller and set metatable to new instance of controller
    local controller_path = self.application.config.controller.path or self.application.config.app.root .. 'application/controllers/'
    local view_path = self.application.config.view.path or self.application.config.app.root .. 'application/views/'

    self.application.ngx.var.template_root=view_path
    self.view = self:initView()
    self.view:init(controller_name, action)

    local matched_controller = require(controller_path .. controller_name)
    local controller_instance = Controller:new(self.request, self.response, self.application.config, self.view)
    setmetatable(matched_controller, { __index = controller_instance })

    -- call action
    local ok, status_or_error, body, headers = pcall(function()
        -- pp(matched_controller .. action)
        if matched_controller[action] == nil then
            error({ code = 104, custom_attrs = {'FFFFFF', 'KKKKKK'} })
        end
        return matched_controller[action](matched_controller)
    end)

    local response

    if ok then
        -- successful
        self.response.body = status_or_error
        return self.response
        -- response = Response.new({ status = 200, headers = err.headers, body = err.body })
    else
        -- controller raised an error
        local ok, errorbody_or_err = pcall(function() return self:raise_error(100, 'FFFFxxxxvv') end)
        -- pp(errorbody_or_err)
        if ok then
            self.response.body = errorbody_or_err
            -- API error
            return self.response
            -- response = Response.new({ status = err.status, headers = err.headers, body = err.body })
        else
        --     -- another error, throw
            error(errorbody_or_err)
        end
    end
    return response
end

function Dispatcher:raise_error(code, msg)
    -- load matched controller and set metatable to new instance of controller
    local controller_path = self.application.config.controller.path or self.application.config.app.root .. 'application/controllers/'

    local error_controller = require(controller_path .. 'error')

    local controller_instance = Controller:new(self.request, self.response, self.application.config, self.view)
    setmetatable(error_controller, { __index = controller_instance })
    -- body
    self.view:init('error', 'error')
    error_controller.err = {}
    error_controller.err.status = code
    error_controller.err.message = msg
    return error_controller:error()
end

function Dispatcher:getApplication()
	return self.application
end

function Dispatcher:getRouter()
end

function Dispatcher:setView(view)
	self.view = view
end

function Dispatcher:initView(controller_name, action)
	if self.view ~= nil then
		return self.view
	end
    local ok, view_or_error = pcall(function() return View:new(self.application.config.view) end)
    if ok == false then
        ngx.say('------View:new Err')
    end
    return view_or_error
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