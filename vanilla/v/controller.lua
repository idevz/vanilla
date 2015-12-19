-- perf
local error = error
local pairs = pairs
local setmetatable = setmetatable

local Controller = {}

function Controller:new(request, response, app_config)
    local instance = {
        app_config = app_config,
        params = request.params,
        request = request,
        response = response,
        view = {}
    }
    setmetatable(instance, {__index = self})
    return instance
end

function Controller:display(view_tpl, values)
    self.view:render(view_tpl, values)
end

function Controller:getRequest()
    return self.request
end

function Controller:getResponse()
    return self.response
end

function Controller:getView()
    return self.view
end

function Controller:initView(view_handle, controller_name, action_name)
    local init_controller = ''
    local init_action = ''
    if view_handle ~= nil then self.view = view_handle end
    if controller_name ~= nil then init_controller = controller_name else init_controller = self.request.controller_name end
    if action_name ~= nil then init_action = action_name else init_action = self.request.action_name  end
    self.view:init(init_controller, init_action)
end

function Controller:redirect(url)
    local togo = url
    if not ngx.re.match(togo, "http") then
        togo = "http://" .. togo
    end
    ngx.redirect(togo)
end

function Controller:raise_error(code, custom_attrs)
    error({ code = code, custom_attrs = custom_attrs })
end

function Controller:accepted_params(param_filters, params)
    local accepted_params = {}
    for _, param in pairs(param_filters) do
        accepted_params[param] = params[param]
    end
    return accepted_params
end

return Controller