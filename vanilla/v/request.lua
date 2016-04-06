-- Request moudle
-- @since 2015-08-17 10:54
-- @author idevz <zhoujing00k@gmail.com>
-- version $Id$

-- perf
local error = error
local pairs = pairs
local pcall = pcall
local setmetatable = setmetatable
local Reqargs = require 'vanilla.v.libs.reqargs'

local Request = {}

function Request:new()
    -- local headers = ngx.req.get_headers()

    -- url:http://zj.com:9210/di0000/111?aa=xx
    local instance = {
        uri = ngx.var.uri,                  -- /di0000/111
        -- req_uri = ngx.var.request_uri,      -- /di0000/111?aa=xx
        -- req_args = ngx.var.args,            -- aa=xx
        -- params = params,
        -- uri_args = ngx.req.get_uri_args(),  -- { aa = "xx" }
        -- method = ngx.req.get_method(),
        -- headers = headers,
        -- body_raw = ngx.req.get_body_data()
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
    local headers = self.headers or ngx.req.get_headers()
    return headers
end

function Request:getHeader(key)
    local headers = self.headers or ngx.req.get_headers()
    if headers[key] ~= nil then
        return headers[key]
    else
        return false
    end
end

function Request:buildParams()
    local GET, POST, FILE = Reqargs:getRequestData({})
    local params = GET
    if #POST >= 1 then for k,v in pairs(POST) do params[k] = v end end
    if #FILE >= 1 then params['VA_FILE']=FILE end
    self.params = params
    return self.params
end

function Request:getParams()
    return self.params or self:buildParams()
end

function Request:getParam(key)
    local ok, params_or_err = pcall(function(self) return self.params[key] end)
    if ok then return params_or_err else return self:buildParams()[key] end
end

function Request:setParam(key, value)
    self.params[key] = value
end

function Request:getMethod()
    local method = self.method or ngx.req.get_method()
    return method
end

function Request:isGet()
    if self.method == 'GET' then return true else return false end
end

return Request