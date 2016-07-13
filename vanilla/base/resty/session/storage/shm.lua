local lock         = require "resty.lock"
local setmetatable = setmetatable
local tonumber     = tonumber
local concat       = table.concat
local now          = ngx.now
local var          = ngx.var
local shared       = ngx.shared

local function enabled(val)
    if val == nil then return nil end
    return val == true or (val == "1" or val == "true" or val == "on")
end

local defaults = {
    store      = var.session_shm_store or "sessions",
    uselocking = enabled(var.session_shm_uselocking or true),
    lock       = {
        exptime  = tonumber(var.session_shm_lock_exptime)  or 30,
        timeout  = tonumber(var.session_shm_lock_timeout)  or 5,
        step     = tonumber(var.session_shm_lock_step)     or 0.001,
        ratio    = tonumber(var.session_shm_lock_ratio)    or 2,
        max_step = tonumber(var.session_shm_lock_max_step) or 0.5,
    }
}

local shm = {}

shm.__index = shm

function shm.new(config)
    local c = config.shm or defaults
    local l = enabled(c.uselocking)
    if l == nil then
        l = defaults.uselocking
    end
    local m = c.store or defaults.store
    local self = {
        store      = shared[m],
        encode     = config.encoder.encode,
        decode     = config.encoder.decode,
        delimiter  = config.cookie.delimiter,
        uselocking = l
    }
    if l then
        local x = c.lock or defaults.lock
        local s = {
            exptime  = tonumber(x.exptime)  or defaults.exptime,
            timeout  = tonumber(x.timeout)  or defaults.timeout,
            step     = tonumber(x.step)     or defaults.step,
            ratio    = tonumber(x.ratio)    or defaults.ratio,
            max_step = tonumber(x.max_step) or defaults.max_step
        }
        self.lock = lock:new(m, s)
    end
    return setmetatable(self, shm)
end

function shm:key(i)
    return self.encode(i)
end

function shm:cookie(c)
    local r, d = {}, self.delimiter
    local i, p, s, e = 1, 1, c:find(d, 1, true)
    while s do
        if i > 2 then
            return nil
        end
        r[i] = c:sub(p, e - 1)
        i, p = i + 1, e + 1
        s, e = c:find(d, p, true)
    end
    if i ~= 3 then
        return nil
    end
    r[3] = c:sub(p)
    return r
end

function shm:open(cookie, lifetime)
    local r = self:cookie(cookie)
    if r and r[1] and r[2] and r[3] then
        local i, e, h = self.decode(r[1]), tonumber(r[2]), self.decode(r[3])
        local k = self:key(i)
        if self.uselocking then
            local l = self.lock
            local ok, err = l:lock(concat{k, ".lock"})
            if ok then
                local s = self.store
                local d = s:get(k)
                s:set(k, d, lifetime)
                l:unlock()
                return i, e, d, h
            end
            return nil, err
        else
            local s = self.store
            local d = s:get(k)
            s:set(k, d, lifetime)
            return i, e, d, h
        end
    end
    return nil, "invalid"
end

function shm:start(i)
    if self.uselocking then
        return self.lock:lock(concat{self:key(i), ".lock"})
    end
    return true, nil
end

function shm:save(i, e, d, h, close)
    local l = e - now()
    if l > 0 then
        local k = self:key(i)
        local ok, err = self.store:set(k, d, l)
        if self.uselocking and close then
            self.lock:unlock()
        end
        if ok then
            return concat({ k, e, self.encode(h) }, self.delimiter)
        end
        return nil, err
    end
    if self.uselocking and close then
        self.lock:unlock()
    end
    return nil, "expired"
end

function shm:destroy(i)
    self.store:delete(self:key(i))
    if self.uselocking then
        self.lock:unlock()
    end
    return true, nil
end

return shm