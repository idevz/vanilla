-- perf
local error = error
local pairs = pairs
local setmetatable = setmetatable
local sfind = string.find
local Request = {}

function Request:new()
    local params = {} -- body params
    local headers = ngx.req.get_headers()

    local header = headers['Content-Type']
    if header then
        local is_multipart = sfind(header, "multipart")
        if is_multipart and is_multipart>0 then
            -- upload request, should not invoke ngx.req.read_body()
        else
            ngx.req.read_body()
            local post_args = ngx.req.get_post_args()
            if post_args and type(post_args) == "table" then
                for k,v in pairs(post_args) do
                    params[k] = v
                end
            end
        end
    else
        ngx.req.read_body()
        local post_args = ngx.req.get_post_args()
        if post_args and type(post_args) == "table" then
            for k,v in pairs(post_args) do
                params[k] = v
            end
        end
    end
    local instance = {
        uri = ngx.var.uri,
        req_uri = ngx.var.request_uri,
        req_args = ngx.var.args,
        params = params,
        uri_args = ngx.req.get_uri_args(),
        method = ngx.req.get_method(), 
        headers = headers, 
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

function Request:getHeaders()
    return self.headers
end

function Request:getHeader(key)
    if self.headers[key] ~= nil then
        return self.headers[key]
    else
        return false
    end
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
