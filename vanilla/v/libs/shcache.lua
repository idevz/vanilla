-- dep
-- https://github.com/cloudflare/lua-resty-shcache
local http_handle = require('vanilla.v.libs.resty.shcache').new()

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