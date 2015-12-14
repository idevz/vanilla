-- perf
local setmetatable = setmetatable
local error = error
local schar = string.char
local sgsub = string.gsub
local sformat = string.format
local tinsert = table.insert
local tconcat = table.concat

local colors_map = {
	-- reset
	reset =      0,

	-- misc
	bright     = 1,
	dim        = 2,
	underline  = 4,
	blink      = 5,
	reverse    = 7,
	hidden     = 8,

	-- foreground colors
	black     = 30,
	red       = 31,
	green     = 32,
	yellow    = 33,
	blue      = 34,
	magenta   = 35,
	cyan      = 36,
	white     = 37,

	-- background colors
	blackbg   = 40,
	redbg     = 41,
	greenbg   = 42,
	yellowbg  = 43,
	bluebg    = 44,
	magentabg = 45,
	cyanbg    = 46,
	whitebg   = 47
}

local function escapeKeys(str)
	local buffer = {}
	local number
	for word in str:gmatch("%w+") do
		number = colors_map[word]
		assert(number, "Unknown colors: " .. word)
		tinsert(buffer, sformat(schar(27) .. '[%dm', number))
	end
	return tconcat(buffer)
end

local function replaceCodes(str)
	str = sgsub(str,"(%%{(.-)})", function(_, str) return escapeKeys(str) end )
	return str
end

local function ansicolors( str )
	str = tostring(str or '')
	return replaceCodes('%{reset}' .. str .. '%{reset}')
end

return setmetatable({noReset = replaceCodes}, {__call = function (_, str) return ansicolors (str) end})