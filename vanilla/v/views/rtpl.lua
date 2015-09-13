-- dep
local template = require "resty.template"

-- perf
local error = error
local setmetatable = setmetatable


local View = {}
View.__index = View

function View:new(view_config)
    local instance = {
        view_config = view_config
    }
    setmetatable(instance, View)
    return instance
end

function View:init(controller_name, action)
    local v = template.new(controller_name .. '/' .. action .. self.view_config.suffix)
    pp(v)
    self.view_handle = template.compile(controller_name .. '/' .. action .. self.view_config.suffix)
    self.controller_name = controller_name
    self.action = action
end

function View:assign(params)
    local ok, body_or_error = pcall(function() return self.view_handle(params) end)
    if ok then
        return body_or_error
    else
        error(body_or_error)
    end
end

function View:caching(cache)
    local cache = cache or true
    template.caching(cache)
end

function View:display()
    -- self.view_handle:render()
end

function View:getScriptPath()
    -- return
end

function View:render(view_tpl, params)
    self.view_handle.render(view_tpl, params)
end

function View:setScriptPath()
end

return View