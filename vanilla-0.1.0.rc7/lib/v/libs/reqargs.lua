-- parse request body to args, this lib come from bungle
-- @since 2016-03-12 6:45
-- @author idevz <zhoujing00k@gmail.com>
-- @see https://github.com/bungle/lua-resty-reqargs
-- version $Id$

-- perf
local upload               = require "resty.upload"
local json_decode          = require "cjson.safe".decode
local os_tmpname           = os.tmpname
local tconcat              = table.concat
local type                 = type
local s_find               = string.find
local io_open              = io.open
local s_sub                = string.sub
local ngx                  = ngx
local ngx_req              = ngx.req
local ngx_var              = ngx.var
local req_read_body        = ngx_req.read_body
local req_get_body_data    = ngx_req.get_body_data
local req_get_post_args    = ngx_req.get_post_args
local req_get_uri_args     = ngx_req.get_uri_args

local function rightmost(s, sep)
    local p = 1
    local i = s_find(s, sep, 1, true)
    while i do
        p = i + 1
        i = s_find(s, sep, p, true)
    end
    if p > 1 then
        s = s_sub(s, p)
    end
    return s
end

local function basename(s)
    return rightmost(rightmost(s, "\\"), "/")
end

local function kv(r, s)
    if s == "formdata" then return end
    local e = s_find(s, "=", 1, true)
    if e then
        r[s_sub(s, 2, e - 1)] = s_sub(s, e + 2, #s - 1)
    else
        r[#r+1] = s
    end
end

local function parse(s)
    if not s then return nil end
    local r = {}
    local i = 1
    local b = s_find(s, ";", 1, true)
    while b do
        local p = s_sub(s, i, b - 1)
        kv(r, p)
        i = b + 1
        b = s_find(s, ";", i, true)
    end
    local p = s_sub(s, i)
    if p ~= "" then kv(r, p) end
    return r
end

local ReqArgs = {}

function ReqArgs:getRequestData(options)
    local GET = req_get_uri_args()
    local POST = {}
    local FILE = {}
    local content_type = ngx_var.content_type
    if content_type == nil then return GET, POST, FILE end
    if s_sub(content_type, 1, 19) == "multipart/form-data" then
        local chunk_size   = options.chunk_size or 8192
        local form, err = upload:new(chunk_size)
        if not form then return nil, err end
        local header, post_data, file_info, out_put_file
        form:set_timeout(options.timeout or 1000)
        while true do
            local res_type, res, err = form:read()
            if not res_type then return nil, err end
            if res_type == "header" then
                if not header then header = {} end
                if type(res) == "table" then
                    local k, v = res[1], parse(res[2])
                    if v then header[k] = v end
                end
            elseif res_type == "body" then
                if header then
                    local header_data = header["Content-Disposition"]
                    if header_data then
                        if header_data.filename then
                            file_info = {
                                name = header_data.name,
                                type = header["Content-Type"] and header["Content-Type"][1],
                                file = basename(header_data.filename),
                                temp = os_tmpname()
                            }
                            out_put_file, err = io_open(file_info.temp, "w+")
                            if not out_put_file then return nil, err end
                            out_put_file:setvbuf("full", chunk)
                        else
                            post_data = { name = header_data.name, data = { n = 1 } }
                        end
                    end
                    h = nil
                end
                if out_put_file then
                    local ok, err = out_put_file:write(res)
                    if not ok then return nil, err end
                elseif post_data then
                    local n = post_data.data.n
                    post_data.data[n] = res
                    post_data.data.n = n + 1
                end
            elseif res_type == "part_end" then
                if out_put_file then
                    file_info.size = out_put_file:seek()
                    out_put_file:close()
                    out_put_file = nil
                end
                local c, d
                if file_info then
                    c, d, file_info = FILE, file_info, nil
                elseif post_data then
                    c, d, post_data = POST, post_data, nil
                end
                if c then
                    local n = d.name
                    local s = d.data and tconcat(d.data) or d
                    if n then
                        local z = c[n]
                        if z then
                            if z.n then
                                z.n = z.n + 1
                                z[z.n] = s
                            else
                                z = { z, s }
                                z.n = 2
                            end
                        else
                            c[n] = s
                        end
                    else
                        c[c.n+1] = s
                        c.n = c.n + 1
                    end
                end
            elseif res_type == "eof" then
                break
            end
        end
        local t, r, e = form:read()
        if not t then return nil, e end
        FILE[1] = true
    elseif s_sub(content_type, 1, 16) == "application/json" then
        req_read_body()
        POST = json_decode(req_get_body_data()) or {}
    else
        req_read_body()
        POST = req_get_post_args()
    end
    return GET, POST, FILE
end

return ReqArgs
