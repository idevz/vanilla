-- perf
local error = error
local pairs = pairs
local setmetatable = setmetatable
local ngx_re_find = ngx.re.find
local ngx_req_read_body = ngx.req.read_body

local Request = {}

function Request:new()
    local is_upload = false
    local headers = ngx.req.get_headers()
    local upload_head = headers['Content-Type']
    if upload_head then
        local is_multipart_head = ngx_re_find(upload_head, [[multipart]], "o")
        if is_multipart_head and is_multipart_head > 0 then is_upload = true end
    end

    local params = ngx.req.get_uri_args()
    if not is_upload then
        ngx_req_read_body()
        for k,v in pairs(ngx.req.get_post_args()) do
            params[k] = v
        end
    end

    -- url:http://zj.com:9210/di0000/111?aa=xx
    local instance = {
        uri = ngx.var.uri,                  -- /di0000/111
        req_uri = ngx.var.request_uri,      -- /di0000/111?aa=xx
        req_args = ngx.var.args,            -- aa=xx
        params = params,
        uri_args = ngx.req.get_uri_args(),  -- { aa = "xx" }
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