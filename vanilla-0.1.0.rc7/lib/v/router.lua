-- perf
local error = error
local tconcat = table.concat
local function tappend(t, v) t[#t+1] = v end
local simple_route = LoadV 'vanilla.v.routes.simple'

-- init Router and set routes
local Router = {}

function Router:new(request)
    local instance = { routes = {simple_route:new(request)} }

    setmetatable(instance, {__index = self})
    return instance
end

function Router:addRoute(route, only_one)
    if route ~= nil then
        if only_one then self.routes = {} end
        tappend(self.routes, route)
    end
end

function Router:removeRoute(route_name)
    for i,route in ipairs(self.routes) do
        if (tostring(route) == route_name) then self.routes[i] = false end
    end
end

function Router:getRoutes()
    return self.routes
end

function Router:getCurrentRoute()
    return self.current_route
end

function Router:getCurrentRouteName()
    return tostring(self.current_route)
end

local function route_match(route)
    return route:match()
end

function Router:route()
    if #self.routes >= 1 then
        local alive_route_num = 0
        local route_err = {}
        for k,route in ipairs(self.routes) do
            if route then
                alive_route_num = alive_route_num + 1
                local ok, controller_name_or_error, action = pcall(route_match, route)
                if ok and controller_name_or_error ~= nil and package.searchpath(Registry['APP_ROOT'] .. '/application/' 
                    .. Registry['CONTROLLER_PREFIX']
                    .. controller_name_or_error, '/?.lua;/?/init.lua') ~= nil
                    -- and type(LoadApplication(Registry['CONTROLLER_PREFIX'] .. controller_name_or_error)[action]) == 'function' 
                    then
                -- if ok and controller_name_or_error then
                    self.current_route = route
                    return controller_name_or_error, action
                else
                    route_err[k] = controller_name_or_error
                end
            end
        end
        error({ code = 201, msg = {
            Routes_No_Match = alive_route_num .. " Routes All Didn't Match. Errs Like: " .. tconcat( route_err, ", ")}})
    end
    error({ code = 201, msg = {Empty_Routes = 'Null routes added.'}})
end

return Router