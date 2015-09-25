-- perf
local setmetatable = setmetatable

local Plugin = {}

function Plugin:routerStartup(request, response)
end

function Plugin:routerShutdown(request, response)
end

function Plugin:dispatchLoopStartup(request, response)
end

function Plugin:preDispatch(request, response)
end

function Plugin:postDispatch(request, response)
end

function Plugin:dispatchLoopShutdown(request, response)
end

function Plugin:new()
    local instance = {
    }
    setmetatable(instance, {__index = self})
    return instance
end

return Plugin