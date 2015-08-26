-- perf
local error = error
local pairs = pairs
local pcall = pcall
local require = require
local setmetatable = setmetatable

local Bootstrap = {}

function Bootstrap:new(dispatcher)
    local instance = {
    	dispatcher = dispatcher,
    }
    setmetatable(instance, {__index = self})
    return instance
end

function Bootstrap:bootstrap()
	pp(self)
	for k,v in pairs(self.bootList()) do
		local ok, request_or_error = pcall(v())
	end
end

return Bootstrap