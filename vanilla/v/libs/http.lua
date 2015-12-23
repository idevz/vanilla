-- dep
-- https://github.com/pintsized/lua-resty-http
local http_handle = require('resty.http').new()

-- perf
local setmetatable = setmetatable

local Http = {}

function Http:new()
	local instance = {
		http_handle = http_handle,
		get = self.get
	}
	setmetatable(instance, Http)
	return instance
end

function Http:get(url, method, params, headers, timeout)
	self.http_handle:set_timeout(timeout)
	local res, err = self.http_handle:request_uri(url, {
		method = method,
		body = params,
		headers = headers
		})
    return res
end

return Http