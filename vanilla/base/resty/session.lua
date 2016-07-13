local require      = require
local var          = ngx.var
local header       = ngx.header
local concat       = table.concat
local hmac         = ngx.hmac_sha1
local time         = ngx.time
local http_time    = ngx.http_time
local find         = string.find
local type         = type
local pcall        = pcall
local tonumber     = tonumber
local setmetatable = setmetatable
local getmetatable = getmetatable
local ffi          = require "ffi"
local ffi_cdef     = ffi.cdef
local ffi_new      = ffi.new
local ffi_str      = ffi.string
local ffi_typeof   = ffi.typeof
local C            = ffi.C

ffi_cdef[[
typedef unsigned char u_char;
int RAND_bytes(u_char *buf, int num);
]]

local t = ffi_typeof "uint8_t[?]"

local function random(len)
    local s = ffi_new(t, len)
    C.RAND_bytes(s, len)
    return ffi_str(s, len)
end

local function enabled(val)
    if val == nil then return nil end
    return val == true or (val == "1" or val == "true" or val == "on")
end

local function setcookie(session, value, expires)
    local c = session.cookie
    local i = 3
    local n = session.name .. "="
    local k = { n, value or "" }
    local d = c.domain
    local x = c.samesite
    if expires then
        k[i] = "; Expires=Thu, 01 Jan 1970 00:00:01 GMT; Max-Age=0"
        i=i+1
    elseif c.persistent then
        k[i]   = "; Expires="
        k[i+1] = http_time(session.expires)
        k[i+2] = "; Max-Age="
        k[i+3] = c.lifetime
        i=i+4
    end
    if d and d ~= "localhost" and d ~= "" then
        k[i]   = "; Domain="
        k[i+1] = d
        i=i+2
    end
    k[i]   = "; Path="
    k[i+1] = c.path or "/"
    i=i+2
    if x == "Lax" or x == "Strict" then
        k[i] = "; SameSite="
        k[i+1] = x
        i=i+2
    end
    if c.secure then
        k[i] = "; Secure"
        i=i+1
    end
    if c.httponly then
        k[i] = "; HttpOnly"
    end
    k = concat(k)
    local s = header["Set-Cookie"]
    local t = type(s)
    if t == "table" then
        local f = false
        local z = #s
        for i=1, z do
            if find(s[i], n, 1, true) == 1 then
                s[i] = k
                f = true
                break
            end
        end
        if not f then
            s[z+1] = k
        end
    elseif t == "string" and find(s, n, 1, true) ~= 1  then
        s = { s, k }
    else
        s = k
    end
    header["Set-Cookie"] = s
    return true
end

local function save(session, close)
    session.expires = time() + session.cookie.lifetime
    local i, e, s = session.id, session.expires, session.storage
    local k = hmac(session.secret, i .. e)
    local d = session.serializer.serialize(session.data)
    local h = hmac(k, concat{ i, e, d, session.key })
    local cookie, err = s:save(i, e, session.cipher:encrypt(d, k, i, session.key), h, close)
    if cookie then
        return setcookie(session, cookie)
    end
    return nil, err
end

local function regenerate(session, flush)
    local i = session.present and session.id or nil
    session.id = random(session.identifier.length)
    if flush then
        if i and session.storage.destroy then
            session.storage:destroy(i);
        end
        session.data = {}
    end
end

local persistent = enabled(var.session_cookie_persistent or false)
local defaults = {
    name       = var.session_name       or "session",
    storage    = var.session_storage    or "cookie",
    serializer = var.session_serializer or "json",
    encoder    = var.session_encoder    or "base64",
    cipher     = var.session_cipher     or "aes",
    cookie = {
        persistent = persistent,
        renew      = tonumber(var.session_cookie_renew)    or 600,
        lifetime   = tonumber(var.session_cookie_lifetime) or 3600,
        path       = var.session_cookie_path               or "/",
        domain     = var.session_cookie_domain,
        samesite   = var.session_cookie_samesite           or "Lax",
        secure     = enabled(var.session_cookie_secure),
        httponly   = enabled(var.session_cookie_httponly   or true),
        delimiter  = var.session_cookie_delimiter          or "|"
    }, check = {
        ssi    = enabled(var.session_check_ssi    or persistent == false),
        ua     = enabled(var.session_check_ua     or true),
        scheme = enabled(var.session_check_scheme or true),
        addr   = enabled(var.session_check_addr   or false)
    }, identifier = {
        length  = tonumber(var.session_identifier_length) or 16
    }
}
defaults.secret = var.session_secret or random(32)

local session = {
    _VERSION = "2.8"
}

session.__index = session

function session.new(opts)
    if getmetatable(opts) == session then
        return opts
    end
    local z = defaults
    local y = opts or z
    local a, b = y.cookie     or z.cookie,     z.cookie
    local c, d = y.check      or z.check,      z.check
    local e, f = y.cipher     or z.cipher,     z.cipher
    local g, h = y.identifier or z.identifier, z.identifier
    local o, i = pcall(require, "resty.session.storage." .. (y.storage or z.storage))
    if not o then
        i = require "resty.session.storage.cookie"
    end
    local o, j = pcall(require, "resty.session.serializers." .. (y.serializer or z.serializer))
    if not o then
        j = require "resty.session.serializers.json"
    end
    local o, k = pcall(require, "resty.session.encoders." .. (y.encoder or z.encoder))
    if not o then
        k = require "resty.session.encoders.base64"
    end
    local o, l = pcall(require, "resty.session.ciphers." .. (e or f))
    if not o then
        l = require "resty.session.ciphers.aes"
    end
    local self = {
        name       = y.name    or z.name,
        serializer = j,
        encoder    = k,
        data       = y.data    or {},
        secret     = y.secret  or z.secret,
        cookie = {
            persistent = a.persistent or b.persistent,
            renew      = a.renew      or b.renew,
            lifetime   = a.lifetime   or b.lifetime,
            path       = a.path       or b.path,
            domain     = a.domain     or b.domain,
            samesite   = a.samesite   or b.samesite,
            secure     = a.secure     or b.secure,
            httponly   = a.httponly   or b.httponly,
            delimiter  = a.delimiter  or b.delimiter
        }, check = {
            ssi        = c.ssi        or d.ssi,
            ua         = c.ua         or d.ua,
            scheme     = c.scheme     or d.scheme,
            addr       = c.addr       or d.addr
        }, identifier = {
            length     = g.length     or h.length
        }
    }
    self.storage = i.new(self)
    self.cipher = l.new(self)
    return setmetatable(self, session)
end

function session.open(opts)
    local self = opts
    if getmetatable(self) == session then
        if self.opened then
            return self, self.present
        end
    else
        self = session.new(opts)
    end
    local scheme = header["X-Forwarded-Proto"]
    if self.cookie.secure == nil then
        if scheme then
            self.cookie.secure = scheme == "https"
        else
            self.cookie.secure = var.https == "on"
        end
    end
    scheme = self.check.scheme and (scheme or var.scheme or "") or ""
    local addr = ""
    if self.check.addr then
        addr = header["CF-Connecting-IP"] or
               header["Fastly-Client-IP"] or
               header["Incap-Client-IP"]  or
               header["X-Real-IP"]
        if not addr then
            addr = header["X-Forwarded-For"]
            if addr then
                -- We shouldn't really get the left-most address, because of spoofing,
                -- but this is better handled with a module, like nginx realip module,
                -- anyway (see also: http://goo.gl/Z6u2oR).
                local s = find(addr, ',', 1, true)
                if s then
                    addr = addr:sub(1, s - 1)
                end
            else
                addr = var.remote_addr
            end
        end
    end
    self.key = concat{
        self.check.ssi and (var.ssl_session_id  or "") or "",
        self.check.ua  and (var.http_user_agent or "") or "",
        addr,
        scheme
    }
    local cookie = var["cookie_" .. self.name]
    if cookie then
        local i, e, d, h = self.storage:open(cookie, self.cookie.lifetime)
        if i and e and e > time() and d and h then
            self.id = i
            self.expires = e
            local k = hmac(self.secret, self.id .. e)
            d = self.cipher:decrypt(d, k, i, self.key)
            if d and hmac(k, concat{ i, e, d, self.key }) == h then
                self.data = self.serializer.deserialize(d)
                self.present = true
            end
        end
    end
    if not self.present then
        regenerate(self)
    end
    if type(self.data) ~= "table" then self.data = {} end
    self.opened = true
    return self, self.present
end

function session.start(opts)
    if getmetatable(opts) == session and opts.started then
        return opts, opts.present
    end
    local self, present = session.open(opts)
    if present then
        if self.storage.start then
            self.storage:start(self.id)
        end
        if self.expires - time() < self.cookie.renew then
            save(self)
        end
    else
        save(self)
    end
    self.started = true
    return self, present
end

function session:regenerate(flush)
    regenerate(self, flush)
    return save(self)
end

function session:save(close)
    if not self.id then
        self.id = random(self.identifier.length)
    end
    return save(self, close ~= false)
end

function session:destroy()
    if self.storage.destroy then
        self.storage:destroy(self.id)
    end
    self.data      = {}
    self.present   = nil
    self.opened    = nil
    self.started   = nil
    self.destroyed = true
    return setcookie(self, "", true)
end

return session