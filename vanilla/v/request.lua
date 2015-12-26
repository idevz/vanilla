-- perf
local error = error
local pairs = pairs
local setmetatable = setmetatable

local Request = {}

function Request:new()
    ngx.req.read_body()
    local params = ngx.req.get_uri_args()
    for k,v in pairs(ngx.req.get_post_args()) do
        params[k] = v
    end

    local instance = {
        uri = ngx.var.uri,
        req_uri = ngx.var.request_uri,
        req_args = ngx.var.args,
        params = params,
        uri_args = ngx.req.get_uri_args(),
        method = ngx.req.get_method(),
        headers = ngx.req.get_headers(),
        body_raw = ngx.req.get_body_data()
    }
    setmetatable(instance, {__index = self})
    return instance
end

function Request:getControllerName()
    return self.controller_name
end

function Request:getActionName()
    return self.action_name
end

function Request:getParams()
    return self.params
end

function Request:getParam(key)
    return self.params[key]
end

function Request:setParam(key, value)
    self.params[key] = value
end

function Request:getMethod()
    return self.method
end

function Request:isGet()
    if self.method == 'GET' then return true else return false end
end

return Request