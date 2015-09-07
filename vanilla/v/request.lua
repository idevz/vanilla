-- dep
local json = require 'cjson'

-- perf
local error = error
local jdecode = json.decode
local pairs = pairs
local pcall = pcall
local rawget = rawget
local setmetatable = setmetatable
local function tappend(t, v) t[#t+1] = v end


local Request = {}
Request.__index = Request

function Request:new(ngx)
    -- read body
    ngx.req.read_body()
    local params = ngx.req.get_uri_args()
    for k,v in pairs(ngx.req.get_post_args()) do
        params[k] = v
    end

    -- init instance
    local instance = {
        ngx = ngx,
        uri = ngx.var.uri,
        params = params,
        method = ngx.var.request_method,
        headers = ngx.req.get_headers(),
        body_raw = ngx.req.get_body_data(),
        __cache = {}
    }
    setmetatable(instance, Request)
    return instance
end

function Request:__index(index)
    local out = rawget(rawget(self, '__cache'), index)
    if out then return out end

    if index == 'uri_params' then
        self.__cache[index] = ngx.req.get_uri_args()
        return self.__cache[index]

    else
        return rawget(self, index)
    end
end

return Request