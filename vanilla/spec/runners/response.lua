-- dep
local json = require 'cjson'


local ResponseSpec = {}
ResponseSpec.__index = ResponseSpec


local function trim(str)
  return str:match'^%s*(.*%S)' or ''
end

function ResponseSpec.new(options)
    options = options or {}

    -- body
    local json_body = {}
    local ok
    if options.body ~= nil and trim(options.body) ~= "" then
        ok, json_body = pcall(function() return json.decode(options.body) end)
        if ok == false then json_body = nil end
    end

    -- init instance
    local instance = {
        status = options.status,
        headers = options.headers or {},
        body = json_body,
        body_raw = options.body
    }
    setmetatable(instance, ResponseSpec)
    return instance
end

return ResponseSpec
