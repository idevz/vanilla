-- perf
local error = error
local setmetatable = setmetatable


local View = {}
View.__index = View

function View:new(controller_name, action, view_config)
end

function View:init(controller_name, action)
end

function View:assign()
end

function View:caching()
end

function View:display()
end

function View:getScriptPath()
end

function View:render()
end

function View:setScriptPath()
end


return View