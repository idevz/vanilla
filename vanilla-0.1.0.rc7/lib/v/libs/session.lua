-- dep
-- https://github.com/bungle/lua-resty-session
local http_handle = require('resty.session').new()

-- perf
local setmetatable = setmetatable

local Session = {}

function Session:new()
	local instance = {
	}
	setmetatable(instance, Session)
	return instance
end

return Session