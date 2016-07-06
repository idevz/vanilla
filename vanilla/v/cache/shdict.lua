local Shdict = Class('vanilla.v.cache.shdict', LoadV('vanilla.v.cache.base'))
local ngx_shdict = ngx.shared
local str_sub = string.sub

local function __construct(self)
	local shdict_conf = Registry['sys_conf']['cache']['shared_dict']
	self.shdict_conf = shdict_conf
	self.cache_instance = ngx_shdict[shdict_conf['dict']]
end

Shdict.__construct = __construct

local function _get_cache_instance(self)
	return self.cache_instance
end
Shdict.getCacheInstance = _get_cache_instance

local function _set(self, key, value, exptime)
	local key = self.parent:cacheKey(key)
	local cache_instance = self.cache_instance
	local exptime = exptime or self.shdict_conf['exptime']
	local succ, err = cache_instance:set(key, value, exptime)
	if not succ then error(err) end
	return true
end
Shdict.set = _set

local function _get(self, key)
	local key = self.parent:cacheKey(key)
	local cache_instance = self.cache_instance
	return cache_instance:get(key)
end
Shdict.get = _get

local function _del(self, key)
	local key = self.parent:cacheKey(key)
	local cache_instance = self.cache_instance
	return cache_instance:delete(key)
end
Shdict.del = _del

return Shdict