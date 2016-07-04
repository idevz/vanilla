-- Config Handle
-- @since 2016-05-17 23:00
-- @author idevz <zhoujing00k@gmail.com>
-- version $Id$

local Handle = Class('vanilla.v.config')
local parse = LoadV('vanilla.v.config.parse')
local save = LoadV('vanilla.v.config.save')

function Handle:__construct(conf_type)
	self.conf_type = conf_type
end

function Handle:get(conf)
	local lines = function(name) return assert(io.open(name)):lines() end
	return parse[self.conf_type](lines, Registry['APP_ROOT'] .. '/' .. conf)
end

function Handle:save(name, t)
	local write = function(name, contents) return assert(io.open(name, "w")):write(contents) end
	save[self.conf_type](write, Registry['APP_ROOT'] .. '/' .. name, t)
	return true
end

return Handle