-- dep:https://github.com/pintsized/lua-resty-http
local resty_http = require 'resty.http'

local str_upper = string.upper
local ngx_encode_args = ngx.encode_args

local Http = Class('vanilla.v.libs.http')

local function __construct(self)
	local http_handle = resty_http.new()
	self.http_handle = http_handle
end
Http.__construct = __construct

local function _request(self, method, url, body, headers, timeout)
	local http_handle = self.http_handle
	local method = method or 'GET'
	local timeout = timeout or 500
	local headers = headers or {}
	local body = body or nil

	if type(body) == 'table' then
		body = ngx_encode_args(body)
	end

	headers["User-Agent"] = 'Vanilla-OpenResty-' .. Registry['VANILLA_VERSION']
	if str_upper(method) == 'POST' then
		headers["Content-Type"] = "application/x-www-form-urlencoded"
	end

	http_handle:set_timeout(timeout)

	local res, err = http_handle:request_uri(url, {
		method = method,
		headers = headers,
		body = body
		})
	if res ~= nil then
		return res
	else
		return false, err
	end
end

local function get(self, ... )
	return _request(self, 'GET', ... )
end
Http.get = get

local function post(self, ... )
	return _request(self, 'POST', ... )
end
Http.post = post

return Http
