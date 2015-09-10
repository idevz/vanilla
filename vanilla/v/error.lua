-- vanilla
local helpers = require 'vanilla.v.libs.utils'

-- perf
local error = error
local pairs = pairs
local setmetatable = setmetatable


-- define error
Error = {}
Error.__index = Error

local function init_errors()
    -- get app errors
    local errors = helpers.try_require('config.errors', {})
    -- add system errors
    errors[100] = { status = 500, message = 'DisPatcher Err: Request init Error.' }
    errors[101] = { status = 412, message = "Invalid Accept header format." }
    errors[102] = { status = 412, message = "Unsupported version specified in the Accept header." }
    errors[103] = { status = 400, message = "Could not parse JSON in body." }
    errors[104] = { status = 400, message = "Body should be a JSON hash." }

    return errors
end

Error.list = init_errors()

function Error:new(code, custom_attrs)
    local err = Error.list[code]
    if err == nil then err = {status = 400, message = 'invalid error code'} end

    local body = {
        code = code,
        message = err.message
    }

    if custom_attrs ~= nil then
        for k,v in pairs(custom_attrs) do body[k] = v end
    end

    local instance = {
        status = err.status,
        body = body
    }
    setmetatable(instance, Error)
    return instance
end

return Error
