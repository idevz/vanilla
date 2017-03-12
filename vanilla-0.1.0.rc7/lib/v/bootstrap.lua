-- perf
local pairs = pairs
local setmetatable = setmetatable
-- local lbootstrap = require 'application.bootstrap'


local Bootstrap = {}

function Bootstrap:new(lboot_instance)
    local instance = {
    	lboot_instance = lboot_instance
    }
    setmetatable(instance, {__index=self})
    return instance
end

function Bootstrap:bootstrap()
	for k,v in pairs(self.lboot_instance:boot_list()) do
		v(self.lboot_instance)
	end
end

return Bootstrap