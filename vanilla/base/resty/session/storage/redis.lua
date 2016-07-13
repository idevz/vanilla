local red          = require "resty.redis"
local setmetatable = setmetatable
local tonumber     = tonumber
local concat       = table.concat
local floor        = math.floor
local sleep        = ngx.sleep
local null         = ngx.null
local now          = ngx.now
local var          = ngx.var

local function enabled(val)
    if val == nil then return nil end
    return val == true or (val == "1" or val == "true" or val == "on")
end

local defaults = {
    prefix       = var.session_redis_prefix                 or "sessions",
    socket       = var.session_redis_socket,
    host         = var.session_redis_host                   or "127.0.0.1",
    port         = tonumber(var.session_redis_port)         or 6379,
    auth         = var.session_redis_auth,
    uselocking   = enabled(var.session_redis_uselocking     or true),
    spinlockwait = tonumber(var.session_redis_spinlockwait) or 10000,
    maxlockwait  = tonumber(var.session_redis_maxlockwait)  or 30,
    pool = {
        timeout  = tonumber(var.session_redis_pool_timeout),
        size     = tonumber(var.session_redis_pool_size)
    }
}

local redis = {}

redis.__index = redis

function redis.new(config)
    local r = config.redis or defaults
    local p = r.pool       or defaults.pool
    local l = enabled(r.uselocking)
    if l == nil then
        l = defaults.uselocking
    end
    local self = {
        redis        = red:new(),
        auth         = r.auth or defaults.auth,
        encode       = config.encoder.encode,
        decode       = config.encoder.decode,
        delimiter    = config.cookie.delimiter,
        prefix       = r.prefix or defaults.prefix,
        uselocking   = l,
        spinlockwait = tonumber(r.spinlockwait) or defaults.spinlockwait,
        maxlockwait  = tonumber(r.maxlockwait)  or defaults.maxlockwait,
        pool = {
            timeout  = tonumber(p.timeout) or defaults.pool.timeout,
            size     = tonumber(p.size)    or defaults.pool.size
        }
    }
    local s = r.socket or defaults.socket
    if s then
        self.socket = s
    else
        self.host = r.host or defaults.host
        self.port = r.port or defaults.port
    end
    return setmetatable(self, redis)
end

function redis:connect()
    local redis = self.redis
    local ok, err
    if self.socket then
        ok, err = redis:connect(self.socket)
    else
        ok, err = redis:connect(self.host, self.port)
    end
    if ok and self.auth then
        ok, err = redis:get_reused_times()
        if ok == 0 then
            ok, err = redis:auth(self.auth)
        end
    end
    return ok, err
end

function redis:set_keepalive()
    local pool = self.pool
    local timeout, size = pool.timeout, pool.size
    if timeout and size then
        return self.redis:set_keepalive(timeout, size)
    end
    if timeout then
        return self.redis:set_keepalive(timeout)
    end
    return self.redis:set_keepalive()
end

function redis:key(i)
    return concat({ self.prefix, self.encode(i) }, ":" )
end

function redis:lock(k)
    if not self.uselocking then
        return true, nil
    end
    local s = self.spinlockwait
    local m = self.maxlockwait
    local w = s / 1000000
    local r = self.redis
    local i = 1000000 / s * m
    local l = concat({ k, "lock" }, "." )
    for _ = 1, i do
        local ok = r:setnx(l, "1")
        if ok then
            return r:expire(l, m + 1)
        end
        sleep(w)
    end
    return false, "no lock"
end

function redis:unlock(k)
    if self.uselocking then
        return self.redis:del(concat({ k, "lock" }, "." ))
    end
    return true, nil
end

function redis:get(k)
    local d = self.redis:get(k)
    return d ~= null and d or nil
end

function redis:set(k, d, l)
    return self.redis:setex(k, l, d)
end

function redis:expire(k, l)
    self.redis:expire(k, l)
end

function redis:delete(k)
    self.redis:del(k)
end

function redis:cookie(c)
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

function redis:open(cookie, lifetime)
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

function redis:start(i)
    local ok, err = self:connect()
    if ok then
        ok, err = self:lock(self:key(i))
        self:set_keepalive()
    end
    return ok, err
end

function redis:save(i, e, d, h, close)
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

function redis:destroy(i)
    local ok, err = self:connect()
    if ok then
        local k = self:key(i)
        self:delete(k)
        self:unlock(k)
        self:set_keepalive()
    end
    return ok, err
end

return redis