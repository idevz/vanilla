-- perf
local error = error
local pairs = pairs
local setmetatable = setmetatable

local Controller = {}

function Controller:new(request, response, app_config, view_handle)
    self:init(app_config)

    local instance = {
        app_config = app_config,
        params = request.params,
        request = request,
        response = response,
        view = view_handle
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

function Controller:initView()
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