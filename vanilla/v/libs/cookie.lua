-- dep
-- https://github.com/cloudflare/lua-resty-cookie
local http_handle = require('resty.cookie').new()

-- perf
local setmetatable = setmetatable

local Cookie = {}

function Cookie:new()
	local instance = {
	}
	setmetatable(instance, Cookie)
	return instance
end

return Cookie