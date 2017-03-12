package.path = './application/?.lua;./application/library/?.lua;./application/?/init.lua;' .. package.path
package.cpath = './application/library/?.so;' .. package.cpath

-- convert true|false to on|off
local function convert_boolean_to_onoff(value)
    if value == true then value = 'on' else value = 'off' end
    return value
end

local Directive = {}

function Directive:new(env)
    local run_env = 'production'
    if env ~= nil then run_env = env end
    local instance = {
        run_env = run_env,
        directiveSets = self.directiveSets
    }
    setmetatable(instance, Directive)
    return instance
end

function Directive:luaPackagePath(lua_path)
    local path = package.path
    if lua_path ~= nil then path = lua_path .. path end
    local res = [[lua_package_path "]] .. path .. [[;;";]]
    return res
end

function Directive:luaPackageCpath(lua_cpath)
    local path = package.cpath
    if lua_cpath ~= nil then path = lua_cpath .. path end
    local res = [[lua_package_cpath "]] .. path .. [[;;";]]
    return res
end

function Directive:codeCache(bool_var)
    local res = [[lua_code_cache ]] .. convert_boolean_to_onoff(bool_var) .. [[;]]
    return res
end

function Directive:luaSharedDict( lua_lib )
    local ok, sh_dict_conf_or_error = pcall(function() return require(lua_lib) end)
    if ok == false then
        return false
    end
    local res = ''
    if sh_dict_conf_or_error ~= nil then
        for name,size in pairs(sh_dict_conf_or_error) do
            res = res .. [[lua_shared_dict ]] .. name .. ' ' .. size .. ';'
        end
    end
    return res
end

function Directive:initByLua(lua_lib)
	if lua_lib == nil then return '' end
    local res = [[init_by_lua require(']] .. lua_lib .. [['):run();]]
    return res
end

function Directive:initByLuaFile(lua_file)
	if lua_file == nil then return '' end
    local res = [[init_by_lua_file ]] .. lua_file .. [[;]]
    return res
end

function Directive:initWorkerByLua(lua_lib)
    if lua_lib == nil then return '' end
    local res = [[init_worker_by_lua require(']] .. lua_lib .. [['):run();]]
    return res
end

function Directive:initWorkerByLuaFile(lua_file)
    if lua_file == nil then return '' end
    local res = [[init_worker_by_lua_file ]] .. lua_file .. [[;]]
    return res
end

function Directive:setByLua(lua_lib)
    if lua_lib == nil then return '' end
    local res = [[set_by_lua require(']] .. lua_lib .. [[');]]
    return res
end

function Directive:setByLuaFile(lua_file)
    if lua_file == nil then return '' end
    local res = [[set_by_lua_file ]] .. lua_file .. [[;]]
    return res
end

function Directive:rewriteByLua(lua_lib)
    if lua_lib == nil then return '' end
    local res = [[rewrite_by_lua require(']] .. lua_lib .. [['):run();]]
    return res
end

function Directive:rewriteByLuaFile(lua_file)
    if lua_file == nil then return '' end
    local res = [[rewrite_by_lua_file ]] .. lua_file .. [[;]]
    return res
end

function Directive:accessByLua(lua_lib)
	if lua_lib == nil then return '' end
    local res = [[access_by_lua require(']] .. lua_lib .. [['):run();]]
    return res
end

function Directive:accessByLuaFile(lua_file)
	if lua_file == nil then return '' end
    local res = [[access_by_lua_file ]] .. lua_file .. [[;]]
    return res
end

function Directive:contentByLua(lua_lib)
    if lua_lib == nil then return '' end
    -- local res = [[content_by_lua require(']] .. lua_lib .. [['):run();]]
    local res = [[location / {
            content_by_lua require(']] .. lua_lib .. [['):run();
        }]]
    return res
end

function Directive:contentByLuaFile(lua_file)
    if lua_file == nil then return '' end
    local res = [[location / {
            content_by_lua_file ]] .. lua_file .. [[;
        }]]
    return res
end

function Directive:headerFilterByLua(lua_lib)
    if lua_lib == nil then return '' end
    local res = [[header_filter_by_lua require(']] .. lua_lib .. [['):run();]]
    return res
end

function Directive:headerFilterByLuaFile(lua_file)
    if lua_file == nil then return '' end
    local res = [[header_filter_by_lua_file ]] .. lua_file .. [[;]]
    return res
end

function Directive:bodyFilterByLua(lua_lib)
    if lua_lib == nil then return '' end
    local res = [[body_filter_by_lua require(']] .. lua_lib .. [['):run();]]
    return res
end

function Directive:bodyFilterByLuaFile(lua_file)
    if lua_file == nil then return '' end
    local res = [[body_filter_by_lua_file ]] .. lua_file .. [[;]]
    return res
end

function Directive:logByLua(lua_lib)
    if lua_lib == nil then return '' end
    local res = [[log_by_lua require(']] .. lua_lib .. [['):run();]]
    return res
end

function Directive:logByLuaFile(lua_file)
    if lua_file == nil then return '' end
    local res = [[log_by_lua_file ]] .. lua_file .. [[;]]
    return res
end

function Directive:directiveSets()
    return {
        ['VA_ENV'] = self.run_env,
        ['PORT'] = 80,
        ['NGX_PATH'] = '',
        ['LUA_PACKAGE_PATH'] = Directive.luaPackagePath,
        ['LUA_PACKAGE_CPATH'] = Directive.luaPackageCpath,
        ['LUA_CODE_CACHE'] = Directive.codeCache,
        -- lua_shared_dict falcon_share 100m;
        ['LUA_SHARED_DICT'] = Directive.luaSharedDict,
        ['INIT_BY_LUA'] = Directive.initByLua,
        ['INIT_BY_LUA_FILE'] = Directive.initByLuaFile,
        ['INIT_WORKER_BY_LUA'] = Directive.initWorkerByLua,
        ['INIT_WORKER_BY_LUA_FILE'] = Directive.initWorkerByLuaFile,
        ['SET_BY_LUA'] = Directive.setByLua,
        ['SET_BY_LUA_FILE'] = Directive.setByLuaFile,
        ['REWRITE_BY_LUA'] = Directive.rewriteByLua,
        ['REWRITE_BY_LUA_FILE'] = Directive.rewriteByLuaFile,
        ['ACCESS_BY_LUA'] = Directive.accessByLua,
        ['ACCESS_BY_LUA_FILE'] = Directive.accessByLuaFile,
        ['CONTENT_BY_LUA'] = Directive.contentByLua,
        ['CONTENT_BY_LUA_FILE'] = Directive.contentByLuaFile,
        ['HEADER_FILTER_BY_LUA'] = Directive.headerFilterByLua,
        ['HEADER_FILTER_BY_LUA_FILE'] = Directive.headerFilterByLuaFile,
        ['BODY_FILTER_BY_LUA'] = Directive.bodyFilterByLua,
        ['BODY_FILTER_BY_LUA_FILE'] = Directive.bodyFilterByLuaFile,
        ['LOG_BY_LUA'] = Directive.logByLua,
        ['LOG_BY_LUA_FILE'] = Directive.logByLuaFile
    }
end

return Directive

--[[

    {{LUA_PACKAGE_PATH}}
    {{LUA_PACKAGE_CPATH}}
    {{LUA_CODE_CACHE}}
    {{LUA_SHARED_DICT}}


    {{INIT_BY_LUA}}
    {{INIT_BY_LUA_FILE}}
    {{INIT_WORKER_BY_LUA}}
    {{INIT_WORKER_BY_LUA_FILE}}
    {{REWRITE_BY_LUA}}
    {{REWRITE_BY_LUA_FILE}}
    {{ACCESS_BY_LUA}}
    {{ACCESS_BY_LUA_FILE}}
    {{HEADER_FILTER_BY_LUA}}
    {{HEADER_FILTER_BY_LUA_FILE}}
    {{BODY_FILTER_BY_LUA}}
    {{BODY_FILTER_BY_LUA_FILE}}
    {{LOG_BY_LUA}}
    {{LOG_BY_LUA_FILE}}
    {{SET_BY_LUA}}
    {{SET_BY_LUA_FILE}}
    {{CONTENT_BY_LUA}}
    {{CONTENT_BY_LUA_FILE}}
]]