local tonumber = tonumber
local format   = string.format
local gsub     = string.gsub
local char     = string.char
local byte     = string.byte

local function byt(c)
    return format('%02x', byte(c or ""))
end

local function chr(c)
    return char(tonumber(c, 16) or 0)
end

local base16 = {}

function base16.encode(v)
    return (gsub(v, ".", byt))
end

function base16.decode(v)
    return (gsub(v, "..", chr))
end

return base16