-- dep
-- https://github.com/cloudflare/lua-resty-shcache
local http_handle = require('resty.shcache')

-- perf
local setmetatable = setmetatable

local Shcache = {}

function Shcache:new()
	local instance = {
	}
	setmetatable(instance, Shcache)
	return instance
end

return Shcache