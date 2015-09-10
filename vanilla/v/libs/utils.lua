-- dep
local lfs = require 'lfs'
local prettyprint = require 'pl.pretty'

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
local function tappend(t, v) t[#t+1] = v end


local Utils = {}

-- try to require
function Utils.try_require(module_name, default)
    local ok, module_or_err = pcall(function() return require(module_name) end)

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

-- check if folder exists
function Utils.folder_exists(folder_path)
    return lfs.attributes(sgsub(folder_path, "\\$",""), "mode") == "directory"
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

-- recursively make directories
function Utils.mkdirs(file_path)
    -- get dir path and parts
    local dir_path = smatch(file_path, "(.*)/.*")
    local parts = Utils.split_path(dir_path)
    -- loop
    local current_dir = nil
    for i = 1, #parts do
        if current_dir == nil then
            current_dir = parts[i]
        else
            current_dir = current_dir .. '/' .. parts[i]
        end
        lfs.mkdir(current_dir)
    end
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

-- pretty print to file
function Utils.pp_to_file(o, file_path)
    prettyprint.dump(o, file_path)
end

function Utils.pps(o)
    return prettyprint.write(o)
end

-- pretty print
function Utils.pp(o)
    prettyprint.dump(o)
end

-- check if folder exists
function folder_exists(folder_path)
    return lfs.attributes(sgsub(folder_path, "\\$",""), "mode") == "directory"
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

function Utils.module_names_in_path(path)
    local modules = {}

    if Utils.folder_exists(path) then
        for file_name in lfs.dir(path) do
            if file_name ~= "." and file_name ~= ".." then
                local file_path = path .. '/' .. file_name
                local attr = lfs.attributes(file_path)
                assert(type(attr) == "table")
                if attr.mode ~= "directory" then
                    local module_name = Utils.get_lua_module_name(file_path)
                    if module_name ~= nil then
                        -- add to modules' list
                        tappend(modules, module_name)
                    end
                end
            end
        end
    end

    return modules
end

return Utils
