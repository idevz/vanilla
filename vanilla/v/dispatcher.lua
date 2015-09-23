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
    self:_init(application)
    local instance = {
        application = application,
        -- setErrorHandler = self.setErrorHandler,
        -- getRequest = self.getRequest,
        -- dispatch = self.dispatch,
        -- errResponse = self.errResponse,
        -- raise_error = self.raise_error,
        -- initView = self.initView,
        -- request = self.request,
        -- callController = self.callController,
        -- lpcall = self.lpcall,
        -- response = self.response,
        plugins = {},
        controller_prefix = 'controllers.',
        error_controller = 'error',
        error_action = 'error'
    }
    setmetatable(instance, {__index = self})
    -- setmetatable(instance, Dispatcher)
    return instance
end

function Dispatcher:_init(application)
	self.request = Request:new()
	self.response = Response:new()
    self.controller = Controller:new(self.request, self.response, application.config)
    self.view = application:lpcall(function() return View:new(application.config.view) end)
end

function Dispatcher:getRequest()
	return self.request
end

function Dispatcher:setRequest(request)
	self.request = request
end

function Dispatcher:getResponse()
    return self.response
end

function Dispatcher:registerPlugin(plugin)
    if plugin ~= nil then table.insert(self.plugins, plugin) end
end

function Dispatcher:_runPlugins(hook)
    for _, plugin in ipairs(self.plugins) do
        if plugin[hook] ~= nil then
            plugin[hook](plugin, self.request, self.response)
        end
    end
end

function Dispatcher:_router()
    self.router = require('vanilla.v.routes.simple'):new(self.request)
    local ok, controller_name_or_error, action= pcall(function() return self.router:match() end)
    if ok and controller_name_or_error then
        self.request.controller_name = controller_name_or_error
        self.request.action_name = action
        return true
    else
        self:errResponse(controller_name_or_error)
    end
end

function Dispatcher:dispatch()
    self:_runPlugins('routerStartup')
	self:_router()
    self:_runPlugins('routerShutdown')
    self:_runPlugins('dispatchLoopStartup')
    local matched_controller = self:lpcall(function() return require(self.controller_prefix .. self.request.controller_name) end)

    self:_runPlugins('preDispatch')
    self:initView()
    setmetatable(matched_controller, { __index = self.controller })

    self.response.body = self:lpcall(function()
            if matched_controller[self.request.action_name] == nil then
                error({ code = 102, msg = {NoAction = self.request.action_name}})
            end
            return matched_controller[self.request.action_name](matched_controller)
        end)
    self:_runPlugins('postDispatch')
    self:_runPlugins('dispatchLoopShutdown')
    self.response:response()
end

function Dispatcher:initView(view)
    if view ~= nil then
        self.view = view
    end
    self.controller:initView(self.view)
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

function Dispatcher:raise_error(err)
    if self.view == nil then
        self.view = self:initView()
    end
pp(err)
    local error_controller = require(self.controller_prefix .. self.error_controller)
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