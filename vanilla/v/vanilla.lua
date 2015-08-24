package.path = './app/controllers/?.lua;' .. package.path

function pp( ... )
    local helpers = require 'vanilla.v.libs.utils'
    helpers.pp(...)
    helpers.pp_to_file(..., '/Users/zj-gin/sina/zj')
end

-- dep
local json = require 'cjson'

-- vanilla
local Gin = require 'vanilla.v.gin'
local Controller = require 'vanilla.v.controller'
local Request = require 'vanilla.v.request'
local Response = require 'vanilla.v.response'
local Error = require 'vanilla.v.error'

-- app
local Routes = require 'config.routes'
local Application = require 'config.application'

-- perf
local error = error
local jencode = json.encode
local pairs = pairs
local pcall = pcall
local require = require
local setmetatable = setmetatable
local smatch = string.match
local function tappend(t, v) t[#t+1] = v end


-- init Vanilla and set routes
local Vanilla = {}

-- response version header
local response_version_header = 'gin/'.. Gin.version

-- accept header for application
local accept_header_matcher = "^application/vnd." .. Application.name .. ".v(%d+)(.*)+json$"


local function create_request(ngx)
    local ok, request_or_error = pcall(function() return Request.new(ngx) end)
    if ok == false then
        -- parsing errors
        local err = Error.new(request_or_error.code, request_or_error.custom_attrs)
        response = Response.new({ status = err.status, body = err.body })
        Vanilla.respond(ngx, response)
        return false
    end
    return request_or_error
end

-- main handler function, called from nginx
function Vanilla.handler(ngx)
    -- add headers
    ngx.header.content_type = 'application/json'
    ngx.header["X-Framework"] = response_version_header;

    -- create request object
    local request = create_request(ngx)
    if request == false then return end

    -- get routes
    local ok, controller_name_or_error, action, params, request = pcall(function() return Vanilla.match(request) end)

    local response

    if ok == false then
        -- match returned an error (for instance a 412 for no header match)
        local err = Error.new(controller_name_or_error.code, controller_name_or_error.custom_attrs)
        response = Response.new({ status = err.status, body = err.body })
        Vanilla.respond(ngx, response)

    elseif controller_name_or_error then
        -- matching routes found
        response = Vanilla.call_controller(request, controller_name_or_error, action, params)
        Vanilla.respond(ngx, response)

    else
        -- no matching routes found
        ngx.exit(ngx.HTTP_NOT_FOUND)
    end
end

-- match request to routes
function Vanilla.match(request)
    local uri = request.uri
    local method = request.method

    -- match version based on headers
    if request.headers['accept'] == nil then error({ code = 100 }) end

    local major_version, rest_version = smatch(request.headers['accept'], accept_header_matcher)
    if major_version == nil then error({ code = 101 }) end

    local routes_dispatchers = Routes.dispatchers[tonumber(major_version)]
    if routes_dispatchers == nil then error({ code = 102 }) end

    -- loop dispatchers to find route
    for i = 1, #routes_dispatchers do
        local dispatcher = routes_dispatchers[i]
        if dispatcher[method] then -- avoid matching if method is not defined in dispatcher
            local match = { smatch(uri, dispatcher.pattern) }

            if #match > 0 then
                local params = {}
                for j = 1, #match do
                    if dispatcher[method].params[j] then
                        params[dispatcher[method].params[j]] = match[j]
                    else
                        tappend(params, match[j])
                    end
                end

                -- set version on request
                request.api_version = major_version .. rest_version
                -- return
                return major_version .. '/' .. dispatcher[method].controller, dispatcher[method].action, params, request
            end
        end
    end
end

-- call the controller
function Vanilla.call_controller(request, controller_name, action, params)
    -- load matched controller and set metatable to new instance of controller
    local matched_controller = require(controller_name)
    local controller_instance = Controller.new(request, params)
    setmetatable(matched_controller, { __index = controller_instance })

    -- call action
    local ok, status_or_error, body, headers = pcall(function() return matched_controller[action](matched_controller) end)

    local response

    if ok then
        -- successful
        response = Response.new({ status = status_or_error, headers = headers, body = body })
    else
        -- controller raised an error
        local ok, err = pcall(function() return Error.new(status_or_error.code, status_or_error.custom_attrs) end)

        if ok then
            -- API error
            response = Response.new({ status = err.status, headers = err.headers, body = err.body })
        else
            -- another error, throw
            error(status_or_error)
        end
    end

    return response
end

function Vanilla.respond(ngx, response)
    -- set status
    ngx.status = response.status
    -- set headers
    for k, v in pairs(response.headers) do
        ngx.header[k] = v
    end
    -- encode body
    local json_body = jencode(response.body)
    -- ensure content-length is set
    ngx.header["Content-Length"] = ngx.header["Content-Length"] or ngx.header["content-length"] or json_body:len()
    -- print body
    ngx.print(json_body)
end

function Vanilla.run()
    ngx.say('====================')
end

return Vanilla