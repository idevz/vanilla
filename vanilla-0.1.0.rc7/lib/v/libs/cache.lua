local Cache = Class('vanilla.v.libs.cache')
local resty_memcached = require 'resty.memcached'
local resty_redis = require 'resty.redis'
local resty_lrucache = require 'resty.lrucache'
local resty_lrucache_ffi = require 'resty.lrucache.pureffi'
local utils = LoadV('vanilla.v.libs.utils')
local str_sub = string.sub

local ngx_crc32 = ngx.crc32_short
local ngx_shdict = ngx.shared

local function __construct(self, handle)
	local handle = handle or 'shared_dict'
	local cache_conf = Registry['sys_conf']['cache']

	self.cache_conf = cache_conf
	self.handle = handle

	local cache_instance
	if handle == 'sh' or handle == 'shared_dict' then
		self.cache_instance = ngx_shdict[cache_conf['shared_dict']['content']]
	elseif handle == 'mc' or handle == 'memcached' then
		local memc, err = resty_memcached:new()
		if not memc then
			-- error("failed to instantiate memcached cache_instance: " .. err)
		end
		memc:set_timeout(cache_conf['memcached']['timeout'])
		self.cache_instance = memc
	elseif handle == 'redis' then
		local red, err = resty_redis:new()
		if err then
			-- error("failed to instantiate redis: " .. err)
		end
		red:set_timeout(cache_conf['redis']['timeout'])
		self.cache_instance = red
	elseif handle == 'lrucache' then
		local lrucache, err = resty_lrucache.new(cache_conf['lrucache']['content'])
		if lrucache == nil then
			-- error("failed to instantiate lrucache: " .. err)
		end
		self.cache_instance = lrucache
	end
end
Cache.__construct = __construct

local function _get_cache_hp(cache_type, cache_conf, key_str, node)
	local cache_arrs = utils.explode(" ", utils.trim(cache_conf[cache_type]["conf"]))
	local cache_arrs_num = #cache_arrs
	local cache_num = ngx_crc32(key_str)%cache_arrs_num + 1
	if node ~= nil then
		if cache_arrs_num >= node then
			cache_num = node
		else
			-- error('Invanidate Node Num')
		end
	end
	local cache_info_arrs = utils.explode(":", cache_arrs[cache_num])
	return cache_info_arrs[1], cache_info_arrs[2]
end

local function _get_cache_instance()
	return self.cache_instance
end
Cache.getCacheInstance = _get_cache_instance

local function _connect_remote_cache(self, cache_type, key, node)
	local handle = self.handle
	local cache_conf = self.cache_conf
	local host, port = _get_cache_hp(cache_type, cache_conf, key, node)
	local ok, err = self.cache_instance:connect(host, port)
	print_r(host)
	if not ok then
		-- error(handle .. " failed to connect: " .. err)
	end
end

local function _useMc(self, key, node)
	_connect_remote_cache(self, 'memcached', key, node)
	return self
end
Cache.useMc = _useMc

local function _useRedis(self, key, node)
	_connect_remote_cache(self, 'redis', key, node)
	return self
end
Cache.useRedis = _useRedis

local function _useLruCache()
	return self
end
Cache.useLruCache = _useLruCache

local function _useSharedDict()
	return self
end
Cache.useSharedDict = _useSharedDict

local function _gen_cache_key(key)
	return Registry['APP_NAME'] .. '_' .. str_sub(ngx.md5(key),1,10)
end
Cache.cacheKey = _gen_cache_key

local function _get(self, key)
	local handle = self.handle
	local cache_instance = self.cache_instance
	local res, flags, get_err = cache_instance:get(_gen_cache_key(key))
	print_r(res)
	if get_err then
		print_r(get_err)
		-- error(handle .. " failed to get : " .. get_err)
		return false, get_err
	end

	if not res then
		-- error(handle .. " not found " .. _gen_cache_key(key))
		return false
	end
	return res
end
Cache.get = _get

local function _set(self, key, value, expiretime)
	local handle = self.handle
	local cache_instance = self.cache_instance
	local expiretime = expiretime or 1000
	local set_ok, set_err
	if handle == 'redis' then
		local redis_key = _gen_cache_key(key)
		set_ok, set_err = cache_instance:set(redis_key, value)
		print_r(cache_instance)
		print_r(self)
		print_r(set_ok)
		cache_instance:expire(redis_key, expiretime)
	else
		set_ok, set_err = cache_instance:set(_gen_cache_key(key), value, expiretime)
	end
	if not set_ok and handle ~= 'lrucache' then
		-- error(handle .. "failed to set: " .. set_err)
		return false, set_err
	end
	return true
end
Cache.set = _set

return Cache