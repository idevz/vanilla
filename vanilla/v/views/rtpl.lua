-- dep
-- https://github.com/bungle/lua-resty-template
local template = require "resty.template"
local Registry = require('vanilla.v.registry'):new('sys')

-- perf
local error = error
local pairs = pairs
local setmetatable = setmetatable
local app_root = Registry:get('app_root')

local View = {}

function View:new(view_config)
    ngx.var.template_root = view_config.path or app_root .. 'application/views/'
    local instance = {
        view_config = view_config,
        init = self.init
    }
    setmetatable(instance, {__index = self})
    return instance
end

function View:init(controller_name, action)
    self.view_handle = template.new(controller_name .. '/' .. action .. self.view_config.suffix)
    self.controller_name = controller_name
    self.action = action
end

function View:assign(key, value)
    if type(key) == 'string' then
        self.view_handle[key] = value
    elseif type(key) == 'table' and value == nil then
        for k,v in pairs(key) do
            self.view_handle[k] = v
        end
    end
end

function View:caching(cache)
    local cache = cache or true
    template.caching(cache)
end

function View:display()
    return tostring(self.view_handle)
end

function View:getScriptPath()
    return ngx.var.template_root
end

function View:render(view_tpl, params)
    local view_handle = template.compile(view_tpl)
    local ok, body_or_error = pcall(function() return view_handle(params) end)
    if ok then
        return body_or_error
    else
        error(body_or_error)
    end
end

function View:setScriptPath(scriptpath)
    if scriptpath ~= nil then ngx.var.template_root = scriptpath end
end

return View