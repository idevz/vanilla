-- dep
local template = require "resty.template"

-- perf
local error = error
local setmetatable = setmetatable


local View = {}
View.__index = View

function View:new(controller_name, action, view_config)
    -- init instance
    local instance = {
        view_config = view_config,
        view_handle = template.new(controller_name .. '/' .. action .. view_config.suffix),
        controller_name = controller_name,
        action = action
    }
    setmetatable(instance, View)
    return instance
end

function View:assign(key, value)
    self.view_handle[key] = value
end

function View:caching(cache)
    local cache = cache or true
    template.caching(cache)
end

function View:display()
    self.view_handle:render()
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