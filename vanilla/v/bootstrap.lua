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
    	boot_list = self.boot_list
    }
    setmetatable(instance, {__index=self})
    return instance
end

function Bootstrap:bootstrap()
	for k,v in pairs(self.boot_list()) do
		v(self)
		-- @todo request_or_error
		-- local ok, request_or_error = pcall(v, self)
	end
end

return Bootstrap