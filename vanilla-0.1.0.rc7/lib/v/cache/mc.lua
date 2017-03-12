local Mc = Class('vanilla.v.cache.mc', LoadV('vanilla.v.cache.base'))
local resty_memcached = require 'resty.memcached'

local function __construct(self)
	local cache_conf = Registry['sys_conf']['cache']['memcached']
	self.cache_conf = cache_conf
	local memc, err = resty_memcached:new()
	if not memc then
		-- error("failed to instantiate memcached cache_instance: " .. err)
	end
	memc:set_timeout(cache_conf['timeout'])
	self.cache_instance = memc
end

Mc.__construct = __construct

local function _get_cache_instance(self)
	return self.cache_instance
end
Mc.getCacheInstance = _get_cache_instance

local function _set(self, key, value, exptime)
	local cache_conf = self.cache_conf
	local cache_instance = self.cache_instance
	local key = self.parent:cacheKey(key)
	self.parent:connect(self, key, node)
	local exptime = exptime or cache_conf['exptime']
	local succ, err = cache_instance:set(key, value, exptime)
	if not succ then error(err) end
	self.parent:set_keepalive(self)
	return true
end
Mc.set = _set

local function _get(self, key)
	local cache_conf = self.cache_conf
	local cache_instance = self.cache_instance
	local key = self.parent:cacheKey(key)
	self.parent:connect(self, key, node)
	local rs, err
	if type(key) == 'string' then
		local flags
		rs, flags, err = cache_instance:get(key)
	else
		rs, err = cache_instance:get(key)
	end
	if err then
		-- error(err)
	end
	self.parent:set_keepalive(self)
	return rs
end
Mc.get = _get

local function _del(self, key)
	local cache_conf = self.cache_conf
	local cache_instance = self.cache_instance
	local key = self.parent:cacheKey(key)
	self.parent:connect(self, key, node)
	local rs, err = cache_instance:delete(key)
	if err then
		-- error(err)
	end
	self.parent:set_keepalive(self)
	return rs
end
Mc.del = _del

return Mc