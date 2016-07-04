-- https://github.com/cloudflare/lua-resty-cookie
local resty_cookie = require 'resty.cookie'

local Cookie = Class('vanilla.v.libs.cookie')

local function __construct(self)
	local ck, err = resty_cookie:new()
    if not ck then
        ngx.log(ngx.ERR, err)
        return
    end
    self.ck = ck
end
Cookie.__construct = __construct

local function _set(self, key, value, opts)
	local ck = self.ck
	local key = key
	local value = value
	local opts = opts or {}

	local expires = opts['expires'] or 3600*24
	local path = opts['path'] or '/'
	local domain = opts['domain'] or Registry['APP_HOST']
	local secure = opts['secure'] or false
	local httponly = opts['httponly'] or true
	local samesite = opts['samesite'] or 'Lax' --Strict
	local extension = opts['extension'] or nil

	local ck_opts = {
		key = key,
		value = value,
		path = path,
		domain = domain,
		max_age = expires,
		secure = secure,
		httponly = httponly,
		samesite = samesite,
		extension = extension
		}

	local ok, err = ck:set(ck_opts)
    if not ok then
        ngx.log(ngx.ERR, err)
        return false, err
    end
    return true
end
Cookie.set = _set

local function _get(self, key)
	local ck = self.ck
	local key = key
	local ok, err = ck:get(key)
	if not ok then
		ngx.log(ngx.ERR, err)
		return false, err
	end
	return ok
end
Cookie.get = _get

local function _get_all(self)
	local ck = self.ck
	local ok, err = ck:get_all()
	if not ok then
		ngx.log(ngx.ERR, err)
		return false, err
	end
	return ok
end
Cookie.getAll = _get_all

return Cookie