package.loaded['config.routes'] = { }
package.loaded['config.application'] = {}
package.loaded['resty.upload'] = {}
package.loaded['resty.memcached'] = {}
package.loaded['resty.lrucache'] = {}
package.loaded['resty.lrucache.pureffi'] = {}
package.loaded['resty.redis'] = {}

LoadV = function ( ... )
    return require(...)
end

local _class = function(_, classname, parent)
    local mttt = {
        __call = function(self, ... )
            return self:new(...)
        end
    }
    local parent_type = type(parent)
    if parent_type ~= "function" and parent_type ~= "table" then
        parent = nil
    end
    local cls = {}
    if parent then
        mttt.__index = parent
        cls.parent = parent
    end
    cls.new = function(self, ...)
        local instance = { class = self }
        setmetatable(instance, self)
        if instance.__construct and type(instance.__construct) == 'function' then
            instance:__construct(...)
        end
        return instance
    end
    cls["is" .. classname]  =true
    cls.__cname = classname
    cls.__index = cls
    setmetatable(cls, mttt)
    return cls
end

local class = {}
Class = setmetatable(class, { __call = function(...) return _class(...) end })

Registry={}
Registry['APP_NAME'] = 'vanilla-app'

local reg = require "rex_pcre"
-- DICT Proxy
-- https://github.com/bsm/fakengx/blob/master/fakengx.lua

local SharedDict = {}

local function set(data, key, value)
  data[key] = {
    value = value,
    info = {expired = false}
  }
end

function SharedDict:new()
  return setmetatable({data = {}}, {__index = self})
end

function SharedDict:get(key)
  return self.data[key] and self.data[key].value, nil
end

function SharedDict:set(key, value)
  set(self.data, key, value)
  return true, nil, false
end

SharedDict.safe_set = SharedDict.set

function SharedDict:add(key, value)
  if self.data[key] ~= nil then
    return false, "exists", false
  end

  set(self.data, key, value)
  return true, nil, false
end

function SharedDict:replace(key, value)
  if self.data[key] == nil then
    return false, "not found", false
  end

  set(self.data, key, value)
  return true, nil, false
end

function SharedDict:delete(key)
  self.data[key] = nil
end

function SharedDict:incr(key, value)
  if not self.data[key] then
    return nil, "not found"
  elseif type(self.data[key].value) ~= "number" then
    return nil, "not a number"
  end

  self.data[key].value = self.data[key].value + value
  return self.data[key].value, nil
end

function SharedDict:flush_all()
  for _, item in pairs(self.data) do
    item.info.expired = true
  end
end

function SharedDict:flush_expired(n)
  local data = self.data
  local flushed = 0

  for key, item in pairs(self.data) do
    if item.info.expired then
      data[key] = nil
      flushed = flushed + 1
      if n and flushed == n then
        break
      end
    end
  end

  self.data = data

  return flushed
end

local shared = {}
local shared_mt = {
  __index = function(self, key)
    if shared[key] == nil then
      shared[key] = SharedDict:new()
    end
    return shared[key]
  end
}

-- NGX Prototype
local protoype = {

  -- Log constants
  STDERR = 0,
  EMERG  = 1,
  ALERT  = 2,
  CRIT   = 3,
  ERR    = 4,
  WARN   = 5,
  NOTICE = 6,
  INFO   = 7,
  DEBUG  = 8,

  -- HTTP Method Constants
  HTTP_GET    = "GET",
  HTTP_HEAD   = "HEAD",
  HTTP_POST   = "POST",
  HTTP_PUT    = "PUT",
  HTTP_DELETE = "DELETE",

  -- HTTP Status Constants
  HTTP_OK                        = 200,
  HTTP_CREATED                   = 201,
  HTTP_ACCEPTED                  = 202,
  HTTP_NO_CONTENT                = 204,
  HTTP_PARTIAL_CONTENT           = 206,
  HTTP_SPECIAL_RESPONSE          = 300,
  HTTP_MOVED_PERMANENTLY         = 301,
  HTTP_MOVED_TEMPORARILY         = 302,
  HTTP_SEE_OTHER                 = 303,
  HTTP_NOT_MODIFIED              = 304,
  HTTP_BAD_REQUEST               = 400,
  HTTP_UNAUTHORIZED              = 401,
  HTTP_FORBIDDEN                 = 403,
  HTTP_NOT_FOUND                 = 404,
  HTTP_NOT_ALLOWED               = 405,
  HTTP_REQUEST_TIME_OUT          = 408,
  HTTP_CONFLICT                  = 409,
  HTTP_LENGTH_REQUIRED           = 411,
  HTTP_PRECONDITION_FAILED       = 412,
  HTTP_REQUEST_ENTITY_TOO_LARGE  = 413,
  HTTP_REQUEST_URI_TOO_LARGE     = 414,
  HTTP_UNSUPPORTED_MEDIA_TYPE    = 415,
  HTTP_RANGE_NOT_SATISFIABLE     = 416,
  HTTP_CLOSE                     = 444,
  HTTP_NGINX_CODES               = 494,
  HTTP_REQUEST_HEADER_TOO_LARGE  = 494,
  HTTP_INTERNAL_SERVER_ERROR     = 500,
  HTTP_NOT_IMPLEMENTED           = 501,
  HTTP_BAD_GATEWAY               = 502,
  HTTP_SERVICE_UNAVAILABLE       = 503,
  HTTP_GATEWAY_TIME_OUT          = 504,
  HTTP_INSUFFICIENT_STORAGE      = 507,

}

_G.ngx = {
    ctx = {},
    exit = function(code) return end,
    print = function(print) return end,
    log = function() end,
    status = 200,
    location = {},
    say = print,
    eof = os.exit,
    header = {},
    socket = { tcp = {} },
    now = function() return os.time() end,
    time = function() return os.time() end,
    timer = {
        at = function() end
        },
    shared = setmetatable({}, shared_mt),
    re = {
        match = reg.match,
        gsub = function(str, pattern, sub)
        local res_str, _, sub_made = reg.gsub(str, pattern, sub)
            return res_str, sub_made
        end
        },
    shared = setmetatable({}, shared_mt),
    req = {
        read_body = function() return {} end,
        get_body_data = function() return {} end,
        get_headers = function() return {} end,
        get_uri_args = function() return {} end,
        get_method = function() return {} end,
        get_post_args = function() return {busted = 'busted'} end,
    },
    encode_base64 = function(str)
        return string.format("base64_%s", str)
    end,
    -- Builds a querystring from a table, separated by `&`
    -- @param `tab`          The key/value parameters
    -- @param `key`          The parent key if the value is multi-dimensional (optional)
    -- @return `querystring` A string representing the built querystring
    encode_args = function(tab, key)
    local query = {}
    local keys = {}

    for k in pairs(tab) do
      keys[#keys+1] = k
    end

    table.sort(keys)

    for _, name in ipairs(keys) do
      local value = tab[name]
      if key then
        name = string.format("%s[%s]", tostring(key), tostring(name))
      end
      if type(value) == "table" then
        query[#query+1] = ngx.encode_args(value, name)
      else
        value = tostring(value)
        if value ~= "" then
          query[#query+1] = string.format("%s=%s", name, value)
        else
          query[#query+1] = name
        end
      end
    end

    return table.concat(query, "&")
    end,
    var = {
        uri = "/users",
        document_root = './',
        VANILLA_VERSION = './test-vanilla',
        request_method = 'GET'
    }
}

for k, v in pairs(protoype) do
_G.ngx[k] = v
end
setmetatable(ngx, getmetatable(protoype))

local config={}
config.name = 'bluebird'

config.vanilla_root = '{{VANILLA_ROOT}}'
config.vanilla_version = '{{VANILLA_VERSION_DIR_STR}}'
config.route='vanilla.v.routes.simple'
config.bootstrap='application.bootstrap'
config.app={}
config.app.root='./'

config.controller={}
config.controller.path=config.app.root .. 'application/controllers/'

config.view={}
config.view.path=config.app.root .. 'application/views/'
config.view.suffix='.html'
config.view.auto_render=true

_G['config'] = config

require 'vanilla.spec.runner'