-- vanilla
local Controller = LoadV 'vanilla.v.controller'
local Request = LoadV 'vanilla.v.request'
local Router = LoadV 'vanilla.v.router'
local Response = LoadV 'vanilla.v.response'
local View = LoadV 'vanilla.v.views.rtpl'
local Error = LoadV 'vanilla.v.error'

-- perf
local error = error
local pairs = pairs
local pcall = pcall
local ngx = ngx
local require = require
local setmetatable = setmetatable
local function tappend(t, v) t[#t+1] = v end

local function new_view(view_conf)
    return View:new(view_conf)
end

local function run_route(router_instance)
    return router_instance:route()
end

local Dispatcher = {}
local mt = {__index = Dispatcher}

function Dispatcher:new(application)
    local request = Request:new()
    local response = Response:new()
    local router = Router:new(request)
    Registry['CONTROLLER_PREFIX'] = 'controllers.'
    local instance = {
        application = application,
        request = request,
        response = response,
        router = router,
        plugins = {},
        -- controller_prefix = 'controllers.',
        error_controller = 'error',
        error_action = 'error'
    }
    return setmetatable(instance, mt)
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
    if plugin ~= nil then tappend(self.plugins, plugin) end
end

function Dispatcher:_runPlugins(hook)
    for _, plugin in ipairs(self.plugins) do
        if plugin[hook] ~= nil then
            plugin[hook](plugin, self.request, self.response)
        end
    end
end

function Dispatcher:getRouter()
    return self.router
end

function Dispatcher:_route()
    local ok, controller_name_or_error, action= pcall(run_route, self.router)
    if ok and controller_name_or_error then
        self.request.controller_name = controller_name_or_error
        self.request.action_name = action
        return true
    else
        self:errResponse(controller_name_or_error)
    end
end

local function require_controller(controller_prefix, controller_name)
    return LoadApplication(controller_prefix .. controller_name)
end

local function call_controller(Dispatcher, matched_controller, controller_name, action_name)
    if matched_controller[action_name] == nil then
        Dispatcher:errResponse({ code = 102, msg = {NoAction = action_name}})
    end
    Dispatcher:initView()
    local body = matched_controller[action_name](matched_controller)
    if body ~= nil then return body
    else
        Dispatcher:errResponse({ code = 104, msg = {Exec_Err = controller_name .. '/' .. action_name}})
    end
end

function Dispatcher:dispatch()
    self:_runPlugins('routerStartup')
    self:_route()
    self:_runPlugins('routerShutdown')
    self.controller = Controller:new(self.request, self.response, self.application.config)
    self.view = self.view or self.application:lpcall(new_view, self.application.config.view)
    self:_runPlugins('dispatchLoopStartup')
    local cls_call = {}
    local matched_controller = self:lpcall(require_controller, Registry['CONTROLLER_PREFIX'], self.request.controller_name)
    self:_runPlugins('preDispatch')
    if matched_controller.parent ~= nil and type(matched_controller.parent) == 'table' then
        setmetatable(matched_controller.parent, {__index = self.controller})
        cls_call = matched_controller()
    elseif matched_controller.__cname ~= nil then
        local mt = getmetatable(matched_controller)
        mt.__index = self.controller
        cls_call = matched_controller()
        setmetatable(cls_call.class, mt)
    else
        cls_call = setmetatable(matched_controller, { __index = self.controller })
    end
    local c_rs = self:lpcall(call_controller, self, cls_call, self.request.controller_name, self.request.action_name)
    self.response.body = c_rs
    self:_runPlugins('postDispatch')
    self.response:response()
    self:_runPlugins('dispatchLoopShutdown')
end

function Dispatcher:initView(view, controller_name, action_name)
    if view ~= nil then self.view = view end
    self.controller:initView(self.view, controller_name, action_name)
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
    if self.controller == nil then self.controller = Controller:new(self.request, self.response, self.application.config) end
    if self.view == nil then self.view = self.application:lpcall(new_view, self.application.config.view) end
    local error_controller = LoadApplication(Registry['CONTROLLER_PREFIX'] .. self.error_controller)
    setmetatable(error_controller, { __index = self.controller })
    self:initView(self.view, self.error_controller, self.error_action)
    local error_instance = Error:new(err.code, err.msg)
    if error_instance ~= false then
        error_controller.err = error_instance
    else
        error_controller.err = Error:new(100, {msg = err})
    end
    self.response:setStatus(error_controller.err.status)
    return error_controller[self.error_action](error_controller)
end

function Dispatcher:getApplication()
    return self.application
end

function Dispatcher:setView(view)
    self.view = view
end

function Dispatcher:returnResponse()
    return self.response
end

function Dispatcher:setDefaultAction(default_action)
    if default_action ~= nil then self.request.action_name = default_action end
end

function Dispatcher:setDefaultController(default_controller)
    if default_controller ~= nil then self.request.controller_name = default_controller end
end

function Dispatcher:setErrorHandler(err_handler)
    if type(err_handler) == 'table' then
        if err_handler['controller'] ~= nil then self.error_controller = err_handler['controller'] end
        if err_handler['action'] ~= nil then self.error_action = err_handler['action'] end
        return true
    end
    return false
end

return Dispatcher
