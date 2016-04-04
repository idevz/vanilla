-- perf
local pairs = pairs
local setmetatable = setmetatable
local lbootstrap = require 'application.bootstrap'

local Bootstrap = {}

function Bootstrap:new(dispatcher)
    local instance = {
    	lboot_instance = lbootstrap:new(dispatcher)
    }
    setmetatable(instance, {__index=self})
    return instance
end

function Bootstrap:bootstrap()
	for k,v in pairs(self.lboot_instance:boot_list()) do
		v(self)
	end
end

return Bootstrap