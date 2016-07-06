local Redis = Class('vanilla.v.cache.redis', LoadV('vanilla.v.cache.base'))
local resty_redis = require 'resty.redis'

local function __construct(self)
	local cache_conf = Registry['sys_conf']['cache']['redis']
	self.cache_conf = cache_conf
	local red, err = resty_redis:new()
	if err then
		-- error("failed to instantiate redis: " .. err)
	end
	red:set_timeout(cache_conf['timeout'])
	self.cache_instance = red
end

Redis.__construct = __construct

local function _get_cache_instance(self)
	return self.cache_instance
end
Redis.getCacheInstance = _get_cache_instance

local function _set(self, key, value, exptime)
	local cache_conf = self.cache_conf
	local cache_instance = self.cache_instance
	local key = self.parent:cacheKey(key)
	-- ngx.log(ngx.ERR, sprint_r(key))
	self.parent:connect(self, key, node)
	local exptime = exptime or cache_conf['exptime']
	local succ, err = cache_instance:set(key, value)
	cache_instance:expire(key, exptime)
	if not succ then error(err) end
	self.parent:set_keepalive(self)
	return true
end
Redis.set = _set

local function _get(self, key)
	local cache_conf = self.cache_conf
	local cache_instance = self.cache_instance
	local key = self.parent:cacheKey(key)
	self.parent:connect(self, key, node)
	local rs, err = cache_instance:get(key)
	if err then
		error(err)
	end
	self.parent:set_keepalive(self)
	return rs
end
Redis.get = _get

local function _del(self, key)
	local cache_conf = self.cache_conf
	local cache_instance = self.cache_instance
	local key = self.parent:cacheKey(key)
	self.parent:connect(self, key, node)
	local rs, err = cache_instance:del(key)
	if err then
		error(err)
	end
	self.parent:set_keepalive(self)
	return rs
end
Redis.del = _del

return Redis