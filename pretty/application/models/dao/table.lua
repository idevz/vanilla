-- local TableDao = require('vanilla.v.model.dao'):new()
local TableDao = {}

function TableDao:set(key, value)
	self.__cache[key] = value
	return true
end

function TableDao:new()
	local instance = {
		set = self.set,
		__cache = {}
	}
	setmetatable(instance, TableDao)
	return instance
end

function TableDao:__index(key)
    local out = rawget(rawget(self, '__cache'), key)
    if out then return out else return false end
end
return TableDao