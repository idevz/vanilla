-- init Simple and set routes
local Simple = {}

function Simple:new(request)

    local instance = {
    	request = request
    }

    setmetatable(instance, {__index = self})
    return instance
end

function Simple:match()
    local uri = self.request.uri
    local method = self.request.method

    return '/index', 'index'
    -- return major_version .. '/' .. dispatcher[method].controller, dispatcher[method].action, params, request

    -- -- match version based on headers
    -- if self.request.headers['accept'] == nil then error({ code = 100 }) end

    -- local major_version, rest_version = smatch(self.request.headers['accept'], accept_header_matcher)
    -- if major_version == nil then error({ code = 101 }) end

    -- local routes_dispatchers = Routes.dispatchers[tonumber(major_version)]
    -- if routes_dispatchers == nil then error({ code = 102 }) end

    -- -- loop dispatchers to find route
    -- for i = 1, #routes_dispatchers do
    --     local dispatcher = routes_dispatchers[i]
    --     if dispatcher[method] then -- avoid matching if method is not defined in dispatcher
    --         local match = { smatch(uri, dispatcher.pattern) }

    --         if #match > 0 then
    --             local params = {}
    --             for j = 1, #match do
    --                 if dispatcher[method].params[j] then
    --                     params[dispatcher[method].params[j]] = match[j]
    --                 else
    --                     tappend(params, match[j])
    --                 end
    --             end

    --             -- set version on request
    --             self.request.api_version = major_version .. rest_version
    --             -- return
    --             return major_version .. '/' .. dispatcher[method].controller, dispatcher[method].action, params, request
    --         end
    --     end
    -- end
end

return Simple