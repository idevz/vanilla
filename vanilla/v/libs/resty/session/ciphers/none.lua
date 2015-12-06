local setmetatable = setmetatable
local singleton
local cipher = {}

cipher.__index = cipher

function cipher.new()
    if singleton == nil then
        singleton = setmetatable({}, cipher)
    end
    return singleton
end

function cipher:encrypt(d)
    return d
end

function cipher:decrypt(d)
    return d
end

return cipher