-- dep
-- https://github.com/cloudflare/lua-resty-logger-socket
local http_handle = require('resty.logger.socket')

-- perf
local setmetatable = setmetatable

local Logs = {}

function Logs:new()
	local instance = {
	}
	setmetatable(instance, Logs)
	return instance
end

return Logs