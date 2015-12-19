local concat       = table.concat
local tonumber     = tonumber
local setmetatable = setmetatable

local cookie = {}

cookie.__index = cookie

function cookie.new(config)
    return setmetatable({
        encode    = config.encoder.encode,
        decode    = config.encoder.decode,
        delimiter = config.cookie.delimiter
    }, cookie)
end

function cookie:cookie(c)
    local r, d = {}, self.delimiter
    local i, p, s, e = 1, 1, c:find(d, 1, true)
    while s do
        if i > 3 then
            return nil
        end
        r[i] = c:sub(p, e - 1)
        i, p = i + 1, e + 1
        s, e = c:find(d, p, true)
    end
    if i ~= 4 then
        return nil
    end
    r[4] = c:sub(p)
    return r
end

function cookie:open(cookie)
    local r = self:cookie(cookie)
    if r and r[1] and r[2] and r[3] and r[4] then
        return self.decode(r[1]), tonumber(r[2]), self.decode(r[3]), self.decode(r[4])
    end
    return nil, "invalid"
end

function cookie:save(i, e, d, h)
    return concat({ self.encode(i), e, self.encode(d), self.encode(h) }, self.delimiter)
end

return cookie