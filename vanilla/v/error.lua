-- vanilla
local helpers = require 'vanilla.v.libs.utils'
local Controller = require 'vanilla.v.controller'

-- perf
local error = error
local pairs = pairs
local setmetatable = setmetatable


-- define error
Error = {}
-- Error.__index = Error

local function init_errors()
    -- get app errors
    local errors = helpers.try_require('config.errors', {})
    -- add system errors
    errors[100] = { status = 412, message = "Accept header not set." }
    errors[101] = { status = 412, message = "Invalid Accept header format." }
    errors[102] = { status = 412, message = "Unsupported version specified in the Accept header." }
    errors[103] = { status = 400, message = "Could not parse JSON in body." }
    errors[104] = { status = 400, message = "Body should be a JSON hash." }

    return errors
end

Error.list = init_errors()

function Error:init_controller(request, response, config, view)
    return Controller:new(request, response, config, view)
    -- body
end

function Error:new(code, custom_attrs)
    local err = Error.list[code] or {}
    if err == nil then error("invalid error code") end

    local body = {
        code = code,
        message = err.message
    }

    local instance = {
        err = err,
        custom_attrs = custom_attrs or {}
    }
    setmetatable(instance, {__index=self})
    return instance
end

return Error
