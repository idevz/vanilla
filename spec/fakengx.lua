local bit    = require 'bit'
local socket = require 'socket'
local sha1   = require 'sha1'
local md5    = require 'md5'
local mime   = require 'mime'
local CRC32  = { 0x00000000, 0x77073096, 0xEE0E612C, 0x990951BA, 0x076DC419, 0x706AF48F, 0xE963A535, 0x9E6495A3, 0x0EDB8832, 0x79DCB8A4, 0xE0D5E91E, 0x97D2D988, 0x09B64C2B, 0x7EB17CBD, 0xE7B82D07, 0x90BF1D91, 0x1DB71064, 0x6AB020F2, 0xF3B97148, 0x84BE41DE, 0x1ADAD47D, 0x6DDDE4EB, 0xF4D4B551, 0x83D385C7, 0x136C9856, 0x646BA8C0, 0xFD62F97A, 0x8A65C9EC, 0x14015C4F, 0x63066CD9, 0xFA0F3D63, 0x8D080DF5, 0x3B6E20C8, 0x4C69105E, 0xD56041E4, 0xA2677172, 0x3C03E4D1, 0x4B04D447, 0xD20D85FD, 0xA50AB56B, 0x35B5A8FA, 0x42B2986C, 0xDBBBC9D6, 0xACBCF940, 0x32D86CE3, 0x45DF5C75, 0xDCD60DCF, 0xABD13D59, 0x26D930AC, 0x51DE003A, 0xC8D75180, 0xBFD06116, 0x21B4F4B5, 0x56B3C423, 0xCFBA9599, 0xB8BDA50F, 0x2802B89E, 0x5F058808, 0xC60CD9B2, 0xB10BE924, 0x2F6F7C87, 0x58684C11, 0xC1611DAB, 0xB6662D3D, 0x76DC4190, 0x01DB7106, 0x98D220BC, 0xEFD5102A, 0x71B18589, 0x06B6B51F, 0x9FBFE4A5, 0xE8B8D433, 0x7807C9A2, 0x0F00F934, 0x9609A88E, 0xE10E9818, 0x7F6A0DBB, 0x086D3D2D, 0x91646C97, 0xE6635C01, 0x6B6B51F4, 0x1C6C6162, 0x856530D8, 0xF262004E, 0x6C0695ED, 0x1B01A57B, 0x8208F4C1, 0xF50FC457, 0x65B0D9C6, 0x12B7E950, 0x8BBEB8EA, 0xFCB9887C, 0x62DD1DDF, 0x15DA2D49, 0x8CD37CF3, 0xFBD44C65, 0x4DB26158, 0x3AB551CE, 0xA3BC0074, 0xD4BB30E2, 0x4ADFA541, 0x3DD895D7, 0xA4D1C46D, 0xD3D6F4FB, 0x4369E96A, 0x346ED9FC, 0xAD678846, 0xDA60B8D0, 0x44042D73, 0x33031DE5, 0xAA0A4C5F, 0xDD0D7CC9, 0x5005713C, 0x270241AA, 0xBE0B1010, 0xC90C2086, 0x5768B525, 0x206F85B3, 0xB966D409, 0xCE61E49F, 0x5EDEF90E, 0x29D9C998, 0xB0D09822, 0xC7D7A8B4, 0x59B33D17, 0x2EB40D81, 0xB7BD5C3B, 0xC0BA6CAD, 0xEDB88320, 0x9ABFB3B6, 0x03B6E20C, 0x74B1D29A, 0xEAD54739, 0x9DD277AF, 0x04DB2615, 0x73DC1683, 0xE3630B12, 0x94643B84, 0x0D6D6A3E, 0x7A6A5AA8, 0xE40ECF0B, 0x9309FF9D, 0x0A00AE27, 0x7D079EB1, 0xF00F9344, 0x8708A3D2, 0x1E01F268, 0x6906C2FE, 0xF762575D, 0x806567CB, 0x196C3671, 0x6E6B06E7, 0xFED41B76, 0x89D32BE0, 0x10DA7A5A, 0x67DD4ACC, 0xF9B9DF6F, 0x8EBEEFF9, 0x17B7BE43, 0x60B08ED5, 0xD6D6A3E8, 0xA1D1937E, 0x38D8C2C4, 0x4FDFF252, 0xD1BB67F1, 0xA6BC5767, 0x3FB506DD, 0x48B2364B, 0xD80D2BDA, 0xAF0A1B4C, 0x36034AF6, 0x41047A60, 0xDF60EFC3, 0xA867DF55, 0x316E8EEF, 0x4669BE79, 0xCB61B38C, 0xBC66831A, 0x256FD2A0, 0x5268E236, 0xCC0C7795, 0xBB0B4703, 0x220216B9, 0x5505262F, 0xC5BA3BBE, 0xB2BD0B28, 0x2BB45A92, 0x5CB36A04, 0xC2D7FFA7, 0xB5D0CF31, 0x2CD99E8B, 0x5BDEAE1D, 0x9B64C2B0, 0xEC63F226, 0x756AA39C, 0x026D930A, 0x9C0906A9, 0xEB0E363F, 0x72076785, 0x05005713, 0x95BF4A82, 0xE2B87A14, 0x7BB12BAE, 0x0CB61B38, 0x92D28E9B, 0xE5D5BE0D, 0x7CDCEFB7, 0x0BDBDF21, 0x86D3D2D4, 0xF1D4E242, 0x68DDB3F8, 0x1FDA836E, 0x81BE16CD, 0xF6B9265B, 0x6FB077E1, 0x18B74777, 0x88085AE6, 0xFF0F6A70, 0x66063BCA, 0x11010B5C, 0x8F659EFF, 0xF862AE69, 0x616BFFD3, 0x166CCF45, 0xA00AE278, 0xD70DD2EE, 0x4E048354, 0x3903B3C2, 0xA7672661, 0xD06016F7, 0x4969474D, 0x3E6E77DB, 0xAED16A4A, 0xD9D65ADC, 0x40DF0B66, 0x37D83BF0, 0xA9BCAE53, 0xDEBB9EC5, 0x47B2CF7F, 0x30B5FFE9, 0xBDBDF21C, 0xCABAC28A, 0x53B39330, 0x24B4A3A6, 0xBAD03605, 0xCDD70693, 0x54DE5729, 0x23D967BF, 0xB3667A2E, 0xC4614AB8, 0x5D681B02, 0x2A6F2B94, 0xB40BBE37, 0xC30C8EA1, 0x5A05DF1B, 0x2D02EF8D }

-- Helpers
local encode_param = function(str)
  return tostring(str):gsub("\n", "\r\n"):gsub("([^%w_])", function (c)
    return string.format("%%%02X", string.byte(c))
  end)
end

local encode_params = function(tab)
  local list = {}
  for k, v in pairs(tab) do
    table.insert(list, encode_param(k) .. "=" .. encode_param(v))
  end
  return table.concat(list, "&")
end

local function reverse_merge(src, defs)
  local opts = {}
  for k,v in pairs(src) do opts[k] = v end
  for k,v in pairs(defs) do
    if src[k] then v = src[k] end
    opts[k] = v
  end
  return opts
end

local function stub_options(opts, method)
  opts = opts or {}
  if method and opts["method"] == nil then opts["method"] = method end
  if type(opts.args) == "table" then opts["args"] = encode_params(opts.args) end
  return opts
end

local function stub_response(res)
  return reverse_merge(res or {},  { status = 200, headers = {}, body = "" })
end

local control_chars = {
  ["\a"] = "\\a",  ["\b"] = "\\b", ["\f"] = "\\f",  ["\n"] = "\\n",
  ["\r"] = "\\r",  ["\t"] = "\\t", ["\v"] = "\\v",  ["\\"] = "\\\\"
}

local function replace_control_char(c)
  return control_chars[c]
end

local function stub_format(uri, opts)
  local pad = 0
  for k,_ in pairs(opts) do
    if k ~= "method" and #k > pad then pad = #k end
  end

  local msg = "  " .. (opts.method or "GET") .. " " .. uri .. "\n"
  for k,v in pairs(opts) do
    if k ~= "method" then
      k   = k .. ":" .. string.rep(" ", pad + 1 - #k)
      msg = msg .. "  " .. k .. v:gsub("(%c)", replace_control_char) .. "\n"
    end
  end
  return msg
end

-- Capture Registry
local Captures = {}

function Captures:new()
  local this = { stubs = {} }
  setmetatable(this, { __index = self })
  return this
end

function Captures:length()
  return #self.stubs
end

function Captures:each(fun)
  for i=self:length(),1,-1 do
    local stub = self.stubs[i]
    fun(stub)
  end
end

function Captures:find(uri, opts)
  opts = stub_options(opts, "GET")

  for i=self:length(),1,-1 do
    local stub = self.stubs[i]
    if uri == stub.uri then
      local is_match = true

      for k,v in pairs(stub.opts) do
        if type(v) == 'function' then
          is_match = v(opts[k])
        elseif type(v) == 'string' and v:sub(1, 2) == "~>" then
          is_match = tostring(opts[k]):match(v:sub(3)) and true
        elseif opts[k] ~= v then
          is_match = false
        end
        if not is_match then break end
      end
      if is_match then return stub end
    end
  end

  return nil
end

function Captures:stub(uri, opts, res)
  local stub = { uri = uri, opts = stub_options(opts), res = stub_response(res), calls = {} }
  table.insert(self.stubs, stub)
  return stub
end

-- TCP Proxy
local TCP = {}

function TCP:new()
  return setmetatable({ host = nil, port = 0, timeout = 0, keepalive = {-1, 0}, data = {} }, { __index = self })
end

function TCP:connect(host, port)
  self.host = host
  self.port = port
  return true, nil
end

function TCP:settimeout(value)
  self.timeout = value
end

function TCP:setkeepalive(...)
  self.keepalive = {...}
end

function TCP:send(msg)
  table.insert(self.data, msg)
end

-- UDP Proxy
local UDP = {}

function UDP:new()
  return setmetatable({ host = nil, port = 0, timeout = 0, data = {}, closed = false }, { __index = self })
end

function UDP:setpeername(host, port)
  self.host = host
  self.port = port
  return true, nil
end

function UDP:settimeout(value)
  self.timeout = value
end

function UDP:send(msg)
  table.insert(self.data, msg)
  return true, nil
end

function UDP:close()
  self.closed = true
  return true, nil
end

-- DICT Proxy
local SharedDict = {}

function SharedDict:new()
  return setmetatable({ data = {} }, { __index = self })
end

function SharedDict:get(key)
  return self.data[key], 0
end

function SharedDict:set(key, value)
  self.data[key] = value
  return true, nil, false
end

function SharedDict:add(key, value)
  if self.data[key] ~= nil then
    return false, "exists", false
  end

  self.data[key] = value
  return true, nil, false
end

function SharedDict:replace(key, value)
  if self.data[key] == nil then
    return false, "not found", false
  end

  self.data[key] = value
  return true, nil, false
end

function SharedDict:delete(key)
  self.data[key] = nil
end

function SharedDict:incr(key, value)
  if not self.data[key] then
    return nil, "not found"
  elseif type(self.data[key]) ~= "number" then
    return nil, "not a number"
  end

  self.data[key] = self.data[key] + value
  return self.data[key], nil
end

-- NGX Prototype
local protoype = {

  -- Log constants
  STDERR = 0,
  EMERG  = 1,
  ALERT  = 2,
  CRIT   = 3,
  ERR    = 4,
  WARN   = 5,
  NOTICE = 6,
  INFO   = 7,
  DEBUG  = 8,

  -- HTTP Method Constants
  HTTP_GET    = "GET",
  HTTP_HEAD   = "HEAD",
  HTTP_POST   = "POST",
  HTTP_PUT    = "PUT",
  HTTP_DELETE = "DELETE",

  -- HTTP Status Constants
  HTTP_OK                        = 200,
  HTTP_CREATED                   = 201,
  HTTP_ACCEPTED                  = 202,
  HTTP_NO_CONTENT                = 204,
  HTTP_PARTIAL_CONTENT           = 206,
  HTTP_SPECIAL_RESPONSE          = 300,
  HTTP_MOVED_PERMANENTLY         = 301,
  HTTP_MOVED_TEMPORARILY         = 302,
  HTTP_SEE_OTHER                 = 303,
  HTTP_NOT_MODIFIED              = 304,
  HTTP_BAD_REQUEST               = 400,
  HTTP_UNAUTHORIZED              = 401,
  HTTP_FORBIDDEN                 = 403,
  HTTP_NOT_FOUND                 = 404,
  HTTP_NOT_ALLOWED               = 405,
  HTTP_REQUEST_TIME_OUT          = 408,
  HTTP_CONFLICT                  = 409,
  HTTP_LENGTH_REQUIRED           = 411,
  HTTP_PRECONDITION_FAILED       = 412,
  HTTP_REQUEST_ENTITY_TOO_LARGE  = 413,
  HTTP_REQUEST_URI_TOO_LARGE     = 414,
  HTTP_UNSUPPORTED_MEDIA_TYPE    = 415,
  HTTP_RANGE_NOT_SATISFIABLE     = 416,
  HTTP_CLOSE                     = 444,
  HTTP_NGINX_CODES               = 494,
  HTTP_REQUEST_HEADER_TOO_LARGE  = 494,
  HTTP_INTERNAL_SERVER_ERROR     = 500,
  HTTP_NOT_IMPLEMENTED           = 501,
  HTTP_BAD_GATEWAY               = 502,
  HTTP_SERVICE_UNAVAILABLE       = 503,
  HTTP_GATEWAY_TIME_OUT          = 504,
  HTTP_INSUFFICIENT_STORAGE      = 507,

}

-- NGX Builder
local fakengx = {}

-- Constructor
function fakengx.new()
  local ngx = {}
  for k, v in pairs(protoype) do
    ngx[k] = v
  end
  setmetatable(ngx, getmetatable(protoype))

  -- Create namespaces
  ngx.req       = {}
  ngx.re        = {}
  ngx.socket    = {}
  ngx.thread    = {}
  ngx.location  = {}
  ngx.shared    = {}

  -- Create shared dict API
  setmetatable(ngx.shared, {
    __index = function(t, k)
      t[k] = SharedDict:new()
      return t[k]
    end
  })

  function ngx._reset()
    ngx.status    = 200
    ngx.var       = {}
    ngx.ctx       = {}
    ngx.header    = {}
    ngx.arg       = {}

    -- Internal Registries
    ngx._captures = Captures:new()
    ngx._sockets  = {}
    ngx._body     = ""
    ngx._log      = ""
    ngx._exit     = nil

    for k,_ in pairs(ngx.shared) do
      ngx.shared[k] = nil
    end
  end

  -- Reset once
  ngx._reset()

  -- http://wiki.nginx.org/HttpLuaModule#ngx.print
  function ngx.print(s)
    ngx._body = ngx._body .. s
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.say
  function ngx.say(s)
    ngx.print(s .. "\n")
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.log
  function ngx.log(level, ...)
    local args = {...}
    for i=1,#args do args[i] = tostring(args[i]) or "nil" end
    ngx._log = ngx._log .. "LOG(" .. tostring(level) .. "): " .. table.concat(args) .. "\n"
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.time
  function ngx.time()
    if not ngx._time then
      ngx._time = os.time()
    end
    return ngx._time
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.update_time
  function ngx.update_time()
    ngx._time = nil
    ngx._now = nil
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.now
  function ngx.now()
    if not ngx._now then
      ngx._now = socket.gettime()
    end
    return ngx._now
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.cookie_time
  function ngx.cookie_time(t)
    return os.date('!%a, %d-%b-%Y %H:%M:%S GMT', t)
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.exit
  function ngx.exit(status)
    if status > ngx.status then ngx.status = status end
    ngx._exit = status
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.crc32_short
  function ngx.crc32_short(s)
    local crc, l, i = 0xFFFFFFFF, string.len(s)
    for i = 1, l, 1 do
     crc = bit.bxor(bit.rshift(crc, 8), CRC32[bit.band(bit.bxor(crc, string.byte(s, i)), 0xFF) + 1])
    end
    return bit.bxor(crc, -1) % 2^32
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.hmac_sha1
  function ngx.hmac_sha1(secret_key, str)
    return sha1.hmac_sha1_binary(secret_key, str)
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.sha1_bin
  function ngx.sha1_bin(str)
    return sha1.sha1_binary(str)
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.md5
  function ngx.md5(str)
    return md5.sumhexa(str)
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.md5_bin
  function ngx.md5_bin(str)
    return md5.sum(str)
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.escape_uri
  function ngx.escape_uri(str)
    return tostring(str):gsub("\n", "\r\n"):gsub("([^%w_ ])", function (c)
      return string.format("%%%02X", string.byte(c))
    end):gsub(" ", "+")
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.unescape_uri
  function ngx.unescape_uri(str)
    return tostring(str):gsub("+", " "):gsub("\r\n", "\n"):gsub("%%(%x%x)", function(h)
      return string.char(tonumber(h,16))
    end)
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.encode_args
  function ngx.encode_args(tab)
    return encode_params(tab)
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.location.capture
  function ngx.location.capture(uri, opts)
    local stub = ngx._captures:find(uri, opts)
    if not stub then
      local msg = "\n\nUnstubbed request:\n\n" .. stub_format(uri, opts or {}) .. "\nStubbed were:\n"
      ngx._captures:each(function(stub)
        msg = msg .. "\n" .. stub_format(stub.uri, stub.opts or {})
      end)
      error(msg)
    end

    table.insert(stub.calls, { uri = uri, opts = opts })
    return stub.res
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.location.capture_multi
  function ngx.location.capture_multi(...)
    local requests  = ...
    local responses = {}
    for i, request in ipairs(requests) do
      table.insert(responses, ngx.location.capture(request[1], request[2]))
    end
    return unpack(responses)
  end

  -- Stub a capture
  function ngx.location.stub(...)
    return ngx._captures:stub(...)
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.req.read_body
  function ngx.req.read_body()
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.socket.tcp
  function ngx.socket.tcp()
    local sock = TCP:new()
    table.insert(ngx._sockets, sock)
    return sock
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.socket.udp
  function ngx.socket.udp()
    local sock = UDP:new()
    table.insert(ngx._sockets, sock)
    return sock
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.encode_base64
  function ngx.encode_base64(s)
    return mime.b64(s)
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.decode_base64
  function ngx.decode_base64(s)
    return mime.unb64(s)
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.thread.spawn
  function ngx.thread.spawn(fun, ...)
    return { fun = fun, args = {...} }
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.thread.wait
  function ngx.thread.wait(thread)
    return true, thread.fun(unpack(thread.args))
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.re.gmatch
  function ngx.re.gmatch(s, pattern)
    return string.gmatch(s, pattern)
  end

  -- http://wiki.nginx.org/HttpLuaModule#ngx.re.match
  function ngx.re.match(s, pattern)
    return string.match(s, pattern)
  end

  return ngx
end

return fakengx
