local memcached    = require "resty.memcached"
local setmetatable = setmetatable
local tonumber     = tonumber
local concat       = table.concat
local floor        = math.floor
local sleep        = ngx.sleep
local now          = ngx.now
local var          = ngx.var

local function enabled(val)
    if val == nil then return nil end
    return val == true or (val == "1" or val == "true" or val == "on")
end

local defaults = {
    prefix       = var.session_memcache_prefix                 or "sessions",
    socket       = var.session_memcache_socket,
    host         = var.session_memcache_host                   or "127.0.0.1",
    port         = tonumber(var.session_memcache_port)         or 11211,
    uselocking   = enabled(var.session_memcache_uselocking     or true),
    spinlockwait = tonumber(var.session_memcache_spinlockwait) or 10000,
    maxlockwait  = tonumber(var.session_memcache_maxlockwait)  or 30,
    pool = {
        timeout  = tonumber(var.session_memcache_pool_timeout),
        size     = tonumber(var.session_memcache_pool_size)
    }
}

local memcache = {}

memcache.__index = memcache

function memcache.new(config)
    local c = config.memcache or defaults
    local p = c.pool          or defaults.pool
    local l = enabled(c.uselocking)
    if l == nil then
        l = defaults.uselocking
    end
    local self = {
        memcache     = memcached:new(),
        encode       = config.encoder.encode,
        decode       = config.encoder.decode,
        delimiter    = config.cookie.delimiter,
        prefix       = c.prefix or defaults.prefix,
        uselocking   = l,
        spinlockwait = tonumber(c.spinlockwait) or defaults.spinlockwait,
        maxlockwait  = tonumber(c.maxlockwait)  or defaults.maxlockwait,
        pool = {
            timeout = tonumber(p.timeout) or defaults.pool.timeout,
            size    = tonumber(p.size)    or defaults.pool.size
        }
    }
    local s = c.socket or defaults.socket
    if s then
        self.socket = s
    else
        self.host = c.host or defaults.host
        self.port = c.port or defaults.port
    end
    return setmetatable(self, memcache)
end

function memcache:connect()
    local socket = self.socket
    if socket then
        return self.memcache:connect(socket)
    end
    return self.memcache:connect(self.host, self.port)
end

function memcache:set_keepalive()
    local pool = self.pool
    local timeout, size = pool.timeout, pool.size
    if timeout and size then
        return self.memcache:set_keepalive(timeout, size)
    end
    if timeout then
        return self.memcache:set_keepalive(timeout)
    end
    return self.memcache:set_keepalive()
end

function memcache:key(i)
    return concat({ self.prefix, self.encode(i) }, ":" )
end

function memcache:lock(k)
    if not self.uselocking then
        return true, nil
    end
    local s = self.spinlockwait
    local m = self.maxlockwait
    local w = s / 1000000
    local c = self.memcache
    local i = 1000000 / s * m
    local l = concat({ k, "lock" }, "." )
    for _ = 1, i do
        local ok = c:add(l, "1", m + 1)
        if ok then
            return true, nil
        end
        sleep(w)
    end
    return false, "no lock"
end

function memcache:unlock(k)
    if self.uselocking then
        return self.memcache:delete(concat({ k, "lock" }, "." ))
    end
    return true, nil
end

function memcache:get(k)
    local d = self.memcache:get(k)
    return d ~= null and d or nil
end

function memcache:set(k, d, l)
    return self.memcache:set(k, d, l)
end

function memcache:expire(k, l)
    self.memcache:touch(k, l)
end

function memcache:delete(k)
    self.memcache:delete(k)
end

function memcache:cookie(c)
    local r, d = {}, self.delimiter
    local i, p, s, e = 1, 1, c:find(d, 1, true)
    while s do
        if i > 2 then return end
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

function memcache:open(cookie, lifetime)
    local c = self:cookie(cookie)
    if c and c[1] and c[2] and c[3] then
        local ok, err = self:connect()
        if ok then
            local i, e, h = self.decode(c[1]), tonumber(c[2]), self.decode(c[3])
            local k = self:key(i)
            ok, err = self:lock(k)
            if ok then
                local d = self:get(k)
                if d then
                    self:expire(k, floor(lifetime))
                end
                self:unlock(k)
                self:set_keepalive()
                return i, e, d, h
            end
            self:set_keepalive()
            return nil, err
        else
            return nil, err
        end
    end
    return nil, "invalid"
end

function memcache:start(i)
    local ok, err = self:connect()
    if ok then
        ok, err = self:lock(self:key(i))
        self:set_keepalive()
    end
    return ok, err
end

function memcache:save(i, e, d, h, close)
    local ok, err = self:connect()
    if ok then
        local l, k = floor(e - now()), self:key(i)
        if l > 0 then
            ok, err = self:set(k, d, l)
            if close then
                self:unlock(k)
            end
            self:set_keepalive()
            if ok then
                return concat({ self.encode(i), e, self.encode(h) }, self.delimiter)
            end
            return ok, err
        end
        if close then
            self:unlock(k)
            self:set_keepalive()
        end
        return nil, "expired"
    end
    return ok, err
end

function memcache:destroy(i)
    local ok, err = self:connect()
    if ok then
        local k = self:key(i)
        self:delete(k)
        self:unlock(k)
        self:set_keepalive()
    end
    return ok, err
end

return memcache