-- dep
local json = require 'cjson'
local template = require "resty.template"

-- perf
local error = error
local jdecode = json.decode
local pcall = pcall
local rawget = rawget
local setmetatable = setmetatable


local View = {}
View.__index = View

function View:new(controller_name, action)

    -- init instance
    local instance = {
        view_handle = template,
        controller_name = controller_name,
        action = action
    }
    setmetatable(instance, View)
    return instance
end

function View:assign(key, value)
    -- local v = self.view_handle.new "index/index.html"
    -- v.key = value
    -- v:render()
    local view = template.new "index/index.html"
    view[key] = value
    view:render()
    ngx.eof()
    -- self.view_handle.message = 'value'
end

function View:caching(cache)
    local cache = cache or true
    self.view_handle.caching(cache)
end

function View:display()
    self.view_handle:render()
end

function View:getScriptPath()
end

function View:render(view_tpl, params)
    -- pp(template)
    self.view_handle.render(view_tpl, params)
end

function View:setScriptPath()
end

return View