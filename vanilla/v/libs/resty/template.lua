local setmetatable = setmetatable
local tostring = tostring
local setfenv = setfenv
local concat = table.concat
local assert = assert
local write = io.write
local open = io.open
local load = load
local type = type
local dump = string.dump
local find = string.find
local gsub = string.gsub
local byte = string.byte
local sub = string.sub

local HTML_ENTITIES = {
    ["&"] = "&amp;",
    ["<"] = "&lt;",
    [">"] = "&gt;",
    ['"'] = "&quot;",
    ["'"] = "&#39;",
    ["/"] = "&#47;"
}

local CODE_ENTITIES = {
    ["{"] = "&#123;",
    ["}"] = "&#125;",
    ["&"] = "&amp;",
    ["<"] = "&lt;",
    [">"] = "&gt;",
    ['"'] = "&quot;",
    ["'"] = "&#39;",
    ["/"] = "&#47;"
}

local ok, newtab = pcall(require, "table.new")
if not ok then newtab = function() return {} end end

local caching, ngx_var, ngx_capture, ngx_null = true
local template = newtab(0, 13);

template._VERSION = "1.5"
template.cache    = {}
template.concat   = concat

local function rpos(view, s)
    while s > 0 do
        local c = sub(view, s, s)
        if c == " " or c == "\t" or c == "\0" or c == "\x0B" then
            s = s - 1
        else
            break;
        end
    end
    return s
end

local function read_file(path)
    local file = open(path, "rb")
    if not file then return nil end
    local content = file:read "*a"
    file:close()
    return content
end

local function load_lua(path)
    return read_file(path) or path
end

local function load_ngx(path)
    local file, location = path, ngx_var.template_location
    if sub(file, 1)  == "/" then file = sub(file, 2) end
    if location and location ~= "" then
        if sub(location, -1) == "/" then location = sub(location, 1, -2) end
        local res = ngx_capture(location .. '/' .. file)
        if res.status == 200 then return res.body end
    end
    local root = ngx_var.template_root or ngx_var.document_root
    if sub(root, -1) == "/" then root = sub(root, 1, -2) end
    return read_file(root .. "/" .. file) or path
end

if ngx then
    template.print = ngx.print or write
    template.load  = load_ngx
    ngx_var, ngx_capture, ngx_null = ngx.var, ngx.location.capture, ngx.null
else
    template.print = write
    template.load  = load_lua
end

local load_chunk

if _VERSION == "Lua 5.1" then
    local context = { __index = function(t, k)
        return t.context[k] or t.template[k] or _G[k]
    end }
    if jit then
        load_chunk = function(view)
            return assert(load(view, nil, "tb", setmetatable({ template = template }, context)))
        end
    else
        load_chunk = function(view)
            local func = assert(loadstring(view))
            setfenv(func, setmetatable({ template = template }, context))
            return func
        end
    end
else
    local context = { __index = function(t, k)
        return t.context[k] or t.template[k] or _ENV[k]
    end }
    load_chunk = function(view)
        return assert(load(view, nil, "tb", setmetatable({ template = template }, context)))
    end
end

function template.caching(enable)
    if enable ~= nil then caching = enable == true end
    return caching
end

function template.output(s)
    if s == nil or s == ngx_null then return "" end
    if type(s) == "function" then return template.output(s()) end
    return tostring(s)
end

function template.escape(s, c)
    if type(s) == "string" then
        if c then return gsub(s, "[}{\">/<'&]", CODE_ENTITIES) end
        return gsub(s, "[\">/<'&]", HTML_ENTITIES)
    end
    return template.output(s)
end

function template.new(view, layout)
    assert(view, "view was not provided for template.new(view, layout).")
    local render, compile = template.render, template.compile
    if layout then
        return setmetatable({ render = function(self, context)
            local context = context or self
            context.blocks = context.blocks or {}
            context.view = compile(view)(context)
            return render(layout, context)
        end }, { __tostring = function(self)
            local context = context or self
            context.blocks = context.blocks or {}
            context.view = compile(view)(context)
            return compile(layout)(context)
        end })
    end
    return setmetatable({ render = function(self, context)
        return render(view, context or self)
    end }, { __tostring = function(self)
        return compile(view)(context or self)
    end })
end

function template.precompile(view, path, strip)
    local chunk = dump(template.compile(view), strip ~= false)
    if path then
        local file = open(path, "wb")
        file:write(chunk)
        file:close()
    end
    return chunk
end

function template.compile(view, key, plain)
    assert(view, "view was not provided for template.compile(view, key, plain).")
    if key == "no-cache" then
        return load_chunk(template.parse(view, plain)), false
    end
    key = key or view
    local cache = template.cache
    if cache[key] then return cache[key], true end
    local func = load_chunk(template.parse(view, plain))
    if caching then cache[key] = func end
    return func, false
end

function template.parse(view, plain)
    assert(view, "view was not provided for template.parse(view, plain).")
    local concat, rpos, find, byte, sub = concat, rpos, find, byte, sub
    if not plain then
        view = template.load(view)
        if byte(sub(view, 1, 1)) == 27 then return view end
    end
    local c = {[[
context=(...) or {}
local function include(v, c)
    return template.compile(v)(c or context)
end
local ___,blocks,layout={},blocks or {}
]]}
    local i, s = 1, find(view, "{", 1, true)
    while s do
        local t, p, d, z, r = sub(view, s + 1, s + 1), s + 2
        if t == "{" then
            local e = find(view, "}}", p, true)
            if e then
                d = concat{"___[#___+1]=template.escape(", sub(view, p, e - 1), ")\n" }
                z = e + 1
            end
        elseif t == "*" then
            local e = (find(view, "*}", p, true))
            if e then
                d = concat{"___[#___+1]=template.output(", sub(view, p, e - 1), ")\n" }
                z = e + 1
            end
        elseif t == "%" then
            local e = find(view, "%}", p, true)
            if e then
                local n = e + 2
                if sub(view, n, n) == "\n" then
                    n = n + 1
                end
                d = concat{sub(view, p, e - 1), "\n" }
                z, r = n - 1, true
            end
        elseif t == "(" then
            local e = find(view, ")}", p, true)
            if e then
                local f = sub(view, p, e - 1)
                local x = (find(f, ",", 2, true))
                if x then
                    d = concat{"___[#___+1]=include([=[", sub(f, 1, x - 1), "]=],", sub(f, x + 1), ")\n"}
                else
                    d = concat{"___[#___+1]=include([=[", f, "]=])\n" }
                end
                z = e + 1
            end
        elseif t == "[" then
            local e = find(view, "]}", p, true)
            if e then
                d = concat{"___[#___+1]=include(", sub(view, p, e - 1), ")\n" }
                z = e + 1
            end
        elseif t == "-" then
            local e = find(view, "-}", p, true)
            if e then
                local x, y = find(view, sub(view, s, e + 1), e + 2, true)
                if x then
                    y = y + 1
                    x = x - 1
                    if sub(view, y, y) == "\n" then
                        y = y + 1
                    end
                    local b = sub(view, p, e - 1)
                    if b == "verbatim" or b == "raw" then
                        d = concat{"___[#___+1]=[=[", sub(view, e + 2, x), "]=]\n" }
                        z, r = y - 1, false
                    else
                        if sub(view, x, x) == "\n" then
                            x = x - 1
                        end
                        d = concat{'blocks["', b, '"]=include[=[', sub(view, e + 2, x), "]=]\n" }
                        z, r = y - 1, true
                    end

                end
            end
        elseif t == "#" then
            local e = find(view, "#}", p, true)
            if e then
                e = e + 2
                if sub(view, e, e) == "\n" then
                    e = e + 1
                end
                d = ""
                z, r = e - 1, true
            end
        end
        if d then
            c[#c+1] = concat{"___[#___+1]=[=[\n", sub(view, i, r and rpos(view, s - 1) or s - 1), "]=]\n" }
            if d ~= "" then
                c[#c+1] = d
            end
            s, i = z, z + 1
        end
        s = find(view, "{", s + 1, true)
    end
    c[#c+1] = concat{"___[#___+1]=[=[\n", sub(view, i), "]=]\n"}
    c[#c+1] = "return layout and include(layout,setmetatable({view=template.concat(___),blocks=blocks},{__index=context})) or template.concat(___)"
    return concat(c)
end

function template.render(view, context, key, plain)
    assert(view, "view was not provided for template.render(view, context, key, plain).")
    return template.print(template.compile(view, key, plain)(context))
end

return template
