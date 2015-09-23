-- perf
local error = error
local pairs = pairs
local setmetatable = setmetatable

local Controller = {}

function Controller:new(request, response, app_config)
    self:init(app_config)

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

function Controller:init(app_config)
end

function Controller:display(view_tpl, values)
    self.view:render(view_tpl, values)
end

function Controller:forward()
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

function Controller:getViewpath()
end

function Controller:initView(view_handle)
    if view_handle ~= nil then self.view = view_handle end
    self.view:init(self.request.controller_name, self.request.action_name)
end

function Controller:redirect()
end

function Controller:render()
end

function Controller:setViewpath ()
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