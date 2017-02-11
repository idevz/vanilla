local Cache = Class('vanilla.v.cache')
local mc = LoadV('vanilla.v.cache.mc')
local lru = LoadV('vanilla.v.cache.lru')
local redis = LoadV('vanilla.v.cache.redis')
local shdict = LoadV('vanilla.v.cache.shdict')

local function __construct(self, handle)
	local handle = handle or 'shared_dict'
	local cache_instance
	if handle == 'sh' or handle == 'shared_dict' then
		self.cache_instance = shdict()
	elseif handle == 'mc' or handle == 'memcached' then
		self.cache_instance = mc()
	elseif handle == 'redis' then
		self.cache_instance = redis()
	elseif handle == 'lru' or handle == 'lrucache' then
		self.cache_instance = lru()
	end
end
Cache.__construct = __construct

local function _get_cache_instance(self)
	return self.cache_instance
end
Cache.getCacheInstance = _get_cache_instance

local function _set(self, ...)
	local cache_instance = self.cache_instance
	self.cache_instance:set(...)
	return true
end
Cache.set = _set

local function _get(self, ...)
	local cache_instance = self.cache_instance
	return cache_instance:get(...)
end
Cache.get = _get

local function _del(self, ... )
	local cache_instance = self.cache_instance
	return cache_instance:del(...)
end
Cache.del = _del

return Cache