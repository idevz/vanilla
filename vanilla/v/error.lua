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
    errors[100] = { status = 500, message = "Syntax Err." }
    errors[101] = { status = 500, message = "DisPatcher Err: Request init Error." }
    errors[102] = { status = 404, message = "DisPatcher Err: Action didn't defined." }
    errors[103] = { status = 500, message = "Controller Err." }

    return errors
end

Error.list = init_errors()

function Error:new(code, custom_attrs)
    local err = Error.list[code]
    if err == nil then return false end

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
