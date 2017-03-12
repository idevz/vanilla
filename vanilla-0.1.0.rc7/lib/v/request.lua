-- Request moudle
-- @since 2015-08-17 10:54
-- @author idevz <zhoujing00k@gmail.com>
-- version $Id$

-- perf
local error = error
local pairs = pairs
local pcall = pcall
local setmetatable = setmetatable
local Reqargs = LoadV 'vanilla.v.libs.reqargs'

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

-- function Request:getControllerName()
--     return self.controller_name
-- end

-- function Request:getActionName()
--     return self.action_name
-- end

function Request:getHeaders()
    if self.headers == nil then self.headers = ngx.req.get_headers() end
    return self.headers
end

function Request:getHeader(key)
    return self:getHeaders()[key]
end

function Request:buildParams()
    local GET, POST, FILE = Reqargs:getRequestData({})
    local params = {}
    params['VA_GET'] = GET
    params['VA_POST'] = POST
    if #FILE >= 1 then params['VA_FILE']=FILE end
    for k,v in pairs(GET) do params[k] = v end
    for k,v in pairs(POST) do params[k] = v end
    self.params = params
    return self.params
end

function Request:GET()
    if self.params ~= nil then return self.params.VA_GET end
    return self:buildParams()['VA_GET']
end

function Request:POST()
    if self.params ~= nil then return self.params.VA_POST end
    return self:buildParams()['VA_POST']
end

function Request:FILE()
    if self.params ~= nil then return self.params.VA_FILE end
    return self:buildParams()['VA_FILE']
end

function Request:getMethod()
    if self.method == nil then self.method = ngx.req.get_method() end
    return self.method
end

function Request:getParams()
    return self.params or self:buildParams()
end

function Request:getParam(key)
    if self.params ~= nil then return self.params[key] end
    return self:buildParams()[key]
end

function Request:setParam(key, value)
    if self.params == nil then self:buildParams() end
    self.params[key] = value
end

function Request:isGet()
    if self:getMethod() == 'GET' then return true else return false end
end

return Request