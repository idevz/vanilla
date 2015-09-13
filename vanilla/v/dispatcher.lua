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
        dispatch = self.dispatch,
        error_controller = 'error',
        error_action = 'error'
    }
    setmetatable(instance, {__index = self})
    return instance
end

function Dispatcher:init(application)
	self.request = Request:new()
	self.response = Response:new()
    self.router = require('vanilla.v.routes.simple'):new(self.request)
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
    	response = self:call_controller(controller_name_or_error, action)
        response:response()
    else
        self:errResponse(controller_name_or_error)
    end
end

function Dispatcher:lpcall( ... )
    local ok, rs_or_error = pcall( ... )
    if ok then
        return rs_or_error
    else
        self:errResponse(rs_or_error)
    end
end

function Dispatcher:errResponse(err)
    self.response.body = self:raise_error(err)
    self.response:response()
    ngx.eof()
end

function Dispatcher:call_controller(controller_name, action)
    local controller_path = self.application.config.controller.path or self.application.config.app.root .. 'application/controllers/'
    local view_path = self.application.config.view.path or self.application.config.app.root .. 'application/views/'

    ngx.var.template_root=view_path
    self.view = self:initView()
    self.view:init(controller_name, action)

    local matched_controller = self:lpcall(function() return require(controller_path .. controller_name) end)
    local controller_instance = Controller:new(self.request, self.response, self.application.config, self.view)
    setmetatable(matched_controller, { __index = controller_instance })

    local response = self.response
    response.body = self:lpcall(function()
            if matched_controller[action] == nil then
                error({ code = 102, msg = {NoAction = action}})
            end
            return matched_controller[action](matched_controller)
        end)
    return response
end

function Dispatcher:raise_error(err)
    local controller_path = self.application.config.controller.path or self.application.config.app.root .. 'application/controllers/'

    if self.view == nil then
        local view_path = self.application.config.view.path or self.application.config.app.root .. 'application/views/'
        ngx.var.template_root=view_path
        self.view = self:initView()
    end

    local error_controller = require(controller_path .. self.error_controller)
    local controller_instance = Controller:new(self.request, self.response, self.application.config, self.view)
    setmetatable(error_controller, { __index = controller_instance })
    self.view:init(self.error_controller, self.error_action)
    local error_instance = Error:new(err.code, err.msg)
    if error_instance ~= false then
        error_controller.err = error_instance
    else
        error_controller.err = Error:new(100, {msg = err})
    end
    return error_controller[self.error_action](error_controller)
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
    return self.application:lpcall(function() return View:new(self.application.config.view) end)
end

function Dispatcher:registerPlugin()
end

function Dispatcher:returnResponse()
    return self.response
end

function Dispatcher:setDefaultAction()
end

function Dispatcher:setDefaultController()
end

function Dispatcher:setDefaultModule()
end

function Dispatcher:setErrorHandler(err_handler)
    if type(err_handler) == 'table' then
        if err_handler['controller'] ~= nil then self.error_controller = err_handler['controller'] end
        if err_handler['action'] ~= nil then self.error_action = err_handler['action'] end
        return true
    end
    return false
end

function Dispatcher:autoRender()
end

function Dispatcher:disableView()
end

function Dispatcher:enableView()
end

return Dispatcher