local Base = Class('vanilla.v.cache.base')
local utils = LoadV('vanilla.v.libs.utils')
local ngx_crc32 = ngx.crc32_short
local str_sub = string.sub

local function _gen_cache_key(parent, key)
	return Registry['APP_NAME'] .. '_' .. str_sub(ngx.md5(key),1,10)
end
Base.cacheKey = _gen_cache_key

local function _get_cache_hp(cache_conf, key_str, node)
	local cache_arrs = utils.explode(" ", utils.trim(cache_conf["instances"]))
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

local function _connect_remote_cache(parent, child, key, node)
	local cache_conf = child.cache_conf
	local host, port = _get_cache_hp(cache_conf, key, node)
	local ok, err = child.cache_instance:connect(host, port)
	if not ok then
		-- error(handle .. " failed to connect: " .. err)
	end
end
Base.connect = _connect_remote_cache

local function _set_keepalive(parent, child)
	ngx.log(ngx.ERR, sprint_r(parent))
	local cache_conf = child.cache_conf
	local poolsize = cache_conf['poolsize']
	local idletimeout = cache_conf['idletimeout']
	local ok, err = child.cache_instance:set_keepalive(idletimeout, poolsize)
	if not ok then
	    error("cannot set keepalive: ", err)
	    return
	end
end
Base.set_keepalive = _set_keepalive

return Base