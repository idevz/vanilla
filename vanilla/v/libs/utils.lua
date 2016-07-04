-- perf
local assert = assert
local iopen = io.open
local pairs = pairs
local pcall = pcall
local require = require
local sfind = string.find
local sgsub = string.gsub
local smatch = string.match
local ssub = string.sub
local type = type
local append = table.insert
local concat = table.concat
local function tappend(t, v) t[#t+1] = v end

local Utils = {}

function Utils.trim (s) 
  return (string.gsub(s, "^%s*(.-)%s*$", "%1")) 
end

function Utils.explode(d,p)
    local t, ll
    t={}
    ll=0
    if(#p == 1) then return {p} end
    while true do
        l=string.find(p,d,ll,true) -- find the next d in the string
        if l~=nil then -- if "not not" found then..
            table.insert(t, string.sub(p,ll,l-1)) -- Save it in our array.
            ll=l+1 -- save just after where we found it for searching next time.
        else
            table.insert(t, string.sub(p,ll)) -- Save what's left in our array.
            break -- Break at end, as it should be, according to the lua manual.
        end
    end
    return t
end

function Utils.lpcall( ... )
    local ok, rs_or_error = pcall( ... )
    if ok then
        return rs_or_error
    else
        Utils.raise_syserror(rs_or_error)
    end
end

function Utils.raise_syserror(err)
    ngx.say('<pre />')
    local s = Utils.sprint_r(err)
    ngx.say(s)
    ngx.eof()
end

local function require_module(module_name)
    return require(module_name)
end

-- try to require
function Utils.try_require(module_name, default)
    local ok, module_or_err = pcall(require_module, module_name)

    if ok == true then return module_or_err end

    if ok == false and smatch(module_or_err, "'" .. module_name .. "' not found") then
        return default
    else
        error(module_or_err)
    end
end

-- read file
function Utils.read_file(file_path)
    local f = iopen(file_path, "rb")
    local content = f:read("*all")
    f:close()
    return content
end

-- split function
function Utils.split(str, pat)
    local t = {}
    local fpat = "(.-)" .. pat
    local last_end = 1
    local s, e, cap = sfind(str, fpat, 1)

    while s do
        if s ~= 1 or cap ~= "" then
            tappend(t,cap)
        end
        last_end = e+1
        s, e, cap = sfind(str, fpat, last_end)
    end

    if last_end <= #str then
        cap = ssub(str, last_end)
        tappend(t, cap)
    end

    return t
end

-- split a path in individual parts
function Utils.split_path(str)
   return Utils.split(str, '[\\/]+')
end

-- value in table?
function Utils.included_in_table(t, value)
    for i = 1, #t do
        if t[i] == value then return true end
    end
    return false
end

-- reverse table
function Utils.reverse_table(t)
    local size = #t + 1
    local reversed = {}
    for i = 1, #t  do
        reversed[size - i] = t[i]
    end
    return reversed
end

--- get the Lua keywords as a set-like table.
-- So `res["and"]` etc would be `true`.
-- @return a table
function Utils.get_keywords ()
    if not lua_keyword then
        lua_keyword = {
            ["and"] = true, ["break"] = true,  ["do"] = true,
            ["else"] = true, ["elseif"] = true, ["end"] = true,
            ["false"] = true, ["for"] = true, ["function"] = true,
            ["if"] = true, ["in"] = true,  ["local"] = true, ["nil"] = true,
            ["not"] = true, ["or"] = true, ["repeat"] = true,
            ["return"] = true, ["then"] = true, ["true"] = true,
            ["until"] = true,  ["while"] = true
        }
    end
    return lua_keyword
end

--- Utility function that finds any patterns that match a long string's an open or close.
-- Note that having this function use the least number of equal signs that is possible is a harder algorithm to come up with.
-- Right now, it simply returns the greatest number of them found.
-- @param s The string
-- @return 'nil' if not found. If found, the maximum number of equal signs found within all matches.
local function has_lquote(s)
    local lstring_pat = '([%[%]])(=*)%1'
    local start, finish, bracket, equals, next_equals = nil, 0, nil, nil, nil
    -- print("checking lquote for", s)
    repeat
        start, finish, bracket, next_equals =  s:find(lstring_pat, finish + 1)
        if start then
            -- print("found start", start, finish, bracket, next_equals)
            --length of captured =. Ex: [==[ is 2, ]] is 0.
            next_equals = #next_equals 
            equals = next_equals >= (equals or 0) and next_equals or equals
        end
    until not start
    --next_equals will be nil if there was no match.
    return   equals 
end

--- Quote the given string and preserve any control or escape characters, such that reloading the string in Lua returns the same result.
-- @param s The string to be quoted.
-- @return The quoted string.
function Utils.quote_string(s)
    --find out if there are any embedded long-quote
    --sequences that may cause issues.
    --This is important when strings are embedded within strings, like when serializing.
    local equal_signs = has_lquote(s) 
    if  s:find("\n") or equal_signs then 
        -- print("going with long string:", s)
        equal_signs =  ("="):rep((equal_signs or -1) + 1)
        --long strings strip out leading \n. We want to retain that, when quoting.
        if s:find("^\n") then s = "\n" .. s end
        --if there is an embedded sequence that matches a long quote, then
        --find the one with the maximum number of = signs and add one to that number
        local lbracket, rbracket =  
            "[" .. equal_signs .. "[",  
            "]" .. equal_signs .. "]"
        s = lbracket .. s .. rbracket
    else
        --Escape funny stuff.
        s = ("%q"):format(s)
    end
    return s
end

local function quote (s)
    if type(s) == 'table' then
        return Utils.write(s,'')
    else
        --AAS
        return Utils.quote_string(s)-- ('%q'):format(tostring(s))
    end
end

local function quote_if_necessary (v)
    if not v then return ''
    else
        --AAS
        if v:find ' ' then v = Utils.quote_string(v) end
    end
    return v
end

local function index (numkey,key)
    --AAS
    if not numkey then 
        key = quote(key) 
         key = key:find("^%[") and (" " .. key .. " ") or key
    end
    return '['..key..']'
end

local function is_identifier (s)
    return type(s) == 'string' and s:find('^[%a_][%w_]*$') and not keywords[s]
end

--- Create a string representation of a Lua table.
--  This function never fails, but may complain by returning an
--  extra value. Normally puts out one item per line, using
--  the provided indent; set the second parameter to '' if
--  you want output on one line.
--  @tab tbl Table to serialize to a string.
--  @string space (optional) The indent to use.
--  Defaults to two spaces; make it the empty string for no indentation
--  @bool not_clever (optional) Use for plain output, e.g {['key']=1}.
--  Defaults to false.
--  @return a string
--  @return a possible error message
function Utils.write (tbl,space,not_clever)
    if type(tbl) ~= 'table' then
        local res = tostring(tbl)
        if type(tbl) == 'string' then return quote(tbl) end
        return res, 'not a table'
    end
    if not keywords then
        keywords = Utils.get_keywords()
    end
    local set = ' = '
    if space == '' then set = '=' end
    space = space or '  '
    local lines = {}
    local line = ''
    local tables = {}


    local function put(s)
        if #s > 0 then
            line = line..s
        end
    end

    local function putln (s)
        if #line > 0 then
            line = line..s
            append(lines,line)
            line = ''
        else
            append(lines,s)
        end
    end

    local function eat_last_comma ()
        local n,lastch = #lines
        local lastch = lines[n]:sub(-1,-1)
        if lastch == ',' then
            lines[n] = lines[n]:sub(1,-2)
        end
    end

    local writeit
    writeit = function (t,oldindent,indent)
        local tp = type(t)
        if tp ~= 'string' and  tp ~= 'table' then
            putln(quote_if_necessary(tostring(t))..',')
        elseif tp == 'string' then
            -- if t:find('\n') then
            --     putln('[[\n'..t..']],')
            -- else
            --     putln(quote(t)..',')
            -- end
            --AAS
            putln(Utils.quote_string(t) ..",")
        elseif tp == 'table' then
            if tables[t] then
                putln('<cycle>,')
                return
            end
            tables[t] = true
            local newindent = indent..space
            putln('{')
            local used = {}
            if not not_clever then
                for i,val in ipairs(t) do
                    put(indent)
                    writeit(val,indent,newindent)
                    used[i] = true
                end
            end
            for key,val in pairs(t) do
                local numkey = type(key) == 'number'
                if not_clever then
                    key = tostring(key)
                    put(indent..index(numkey,key)..set)
                    writeit(val,indent,newindent)
                else
                    if not numkey or not used[key] then -- non-array indices
                        if numkey or not is_identifier(key) then
                            key = index(numkey,key)
                        end
                        put(indent..key..set)
                        writeit(val,indent,newindent)
                    end
                end
            end
            tables[t] = nil
            eat_last_comma()
            putln(oldindent..'},')
        else
            putln(tostring(t)..',')
        end
    end
    writeit(tbl,'',space)
    eat_last_comma()
    return concat(lines,#space > 0 and '\n' or '')
end

function Utils.sprint_r(o)
    return Utils.write(o)
end

-- get the lua module name
function Utils.get_lua_module_name(file_path)
    return smatch(file_path, "(.*)%.lua")
end

-- shallow copy of a table
function Utils.shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function Utils.basename(str)
    local name = sgsub(str, "(.*/)(.*)", "%2")
    return name
end

function Utils.dirname(str)
    if str:match(".-/.-") then
        local name = sgsub(str, "(.*/)(.*)", "%1")
        return name
    else
        return ''
    end
end

return Utils
