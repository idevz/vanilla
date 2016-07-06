local Lru = Class('vanilla.v.cache.lru', LoadV('vanilla.v.cache.base'))
local resty_lrucache = require 'resty.lrucache'
local resty_lrucache_ffi = require 'resty.lrucache.pureffi'

local function __construct(self)
	if Registry['lrucache_instance'] then return end
	local cache_conf = Registry['sys_conf']['cache']['lrucache']
	self.cache_conf = cache_conf
	local lrucache, err
	if cache_conf['useffi'] then
		lrucache, err = resty_lrucache_ffi.new(cache_conf['items'])
	else
		lrucache, err = resty_lrucache.new(cache_conf['items'])
	end
	if lrucache == nil then
		error("failed to instantiate lrucache: " .. err)
	end
	Registry['lrucache_instance'] = lrucache
end

Lru.__construct = __construct

local function _get_cache_instance(self)
	return Registry['lrucache_instance']
end
Lru.getCacheInstance = _get_cache_instance

local function _set(self, key, value, exptime)
	local key = self.parent:cacheKey(key)
	local cache_conf = self.cache_conf
	local cache_instance = Registry['lrucache_instance']
	local exptime = exptime or cache_conf['exptime']
	cache_instance:set(key, value, exptime)
	return true
end
Lru.set = _set

local function _get(self, key)
	local key = self.parent:cacheKey(key)
	local cache_instance = Registry['lrucache_instance']
	return cache_instance:get(key)
end
Lru.get = _get

local function _del(self, key)
	local key = self.parent:cacheKey(key)
	local cache_instance = Registry['lrucache_instance']
	return cache_instance:delete(key)
end
Lru.del = _del

return Lru