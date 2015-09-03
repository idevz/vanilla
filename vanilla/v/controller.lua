-- vanilla
local View = require 'vanilla.v.view'

-- perf
local error = error
local pairs = pairs
local setmetatable = setmetatable


local Controller = {}
Controller.__index = Controller

function Controller:new(request, params, view_path, controller_name, action)
    self:init(view_path, controller_name, action)
    params = params or {}

    local instance = {
        params = params,
        request = request
    }
    setmetatable(instance, Controller)
    return instance
end

function Controller:init(view_path, controller_name, action)
    local ok, view_or_error = pcall(function() return View:new(view_path, controller_name, action) end)
    if ok == false then
        ngx.say('------View:new Err')
    end
    self.view = view_or_error
end

function Controller:display()
end

function Controller:forward()
end

function Controller:getRequest()
end

function Controller:getResponse()
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