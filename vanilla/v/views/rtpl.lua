-- dep
local template = require "resty.template"

-- perf
local error = error
local setmetatable = setmetatable


local View = {}
View.__index = View

function View:new(view_config)
    -- init instance
    local instance = {
        view_config = view_config,
    }
    setmetatable(instance, View)
    return instance
end

function View:init(controller_name, action)
    self.view_handle = template.new(controller_name .. '/' .. action .. self.view_config.suffix)
    -- pp(self.view_handle)
    -- pp(controller_name .. '/' .. action .. self.view_config.suffix)
    self.controller_name = controller_name
    self.action = action
end

function View:assign(key, value)
    self.view_handle[key] = value
    -- pp(self.view_handle)
    -- if self.view_config.auto_render == true then
    --     self:display()
    -- end
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