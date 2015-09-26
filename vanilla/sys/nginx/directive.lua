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

function Directive:codeCache(bool_var)
    local res = [[lua_code_cache ]] .. convert_boolean_to_onoff(bool_var) .. [[;]]
    return res
end

function Directive:initByLua(lua_lib)
	if lua_lib == nil then return '' end
    local res = [[init_by_lua require(']] .. lua_lib .. [[');]]
    return res
end

function Directive:initByLuaFile(lua_file)
	if lua_file == nil then return '' end
    local res = [[init_by_lua_file ]] .. lua_file .. [[;]]
    return res
end

function Directive:accByLua(lua_lib)
	if lua_lib == nil then return '' end
    local res = [[access_by_lua require(']] .. lua_lib .. [[');]]
    return res
end

function Directive:accByLuaFile(lua_file)
	if lua_file == nil then return '' end
    local res = [[access_by_lua_file ]] .. lua_file .. [[;]]
    return res
end

function Directive:contentByLua(lua_lib)
	if lua_lib == nil then return '' end
    local res = [[content_by_lua require(']] .. lua_lib .. [[');]]
    return res
end

function Directive:contentByLuaFile(lua_file)
	if lua_file == nil then return '' end
    local res = [[location / {
    		content_by_lua_file ]] .. lua_file .. [[;
    	}]]
    return res
end

function Directive:luaPackagePath(lua_path)
	local path = './application/?.lua;' .. './application/library/?.lua;'
	if lua_path ~= nil then path = path .. lua_path end
    path = path .. './?.lua;'
    local res = [[lua_package_path "]] .. path .. package.path .. [[;/?.lua;/lib/?.lua;;";]]
    return res
end

function Directive:luaPackageCpath(lua_cpath)
	local path = './application/library/?.so;'
	if lua_cpath ~= nil then path = path .. lua_cpath end
    path = path .. './?.so;'
    local res = [[lua_package_cpath "]] .. path .. package.cpath .. [[;/?.so;/lib/?.so;;";]]
    return res
end

function Directive:directiveSets()
    return {
        ['VA_ENV'] = self.run_env,
        -- lua_shared_dict falcon_share 100m;
        -- ['LUA_SHARED_DICT'] = Directive.luaSharedDict,
        ['LUA_CODE_CACHE'] = Directive.codeCache,
        ['INIT_BY_LUA'] = Directive.initByLua,
        ['INIT_BY_LUA_FILE'] = Directive.initByLuaFile,
        ['ACCESS_BY_LUA'] = Directive.accByLua,
        ['ACCESS_BY_LUA_FILE'] = Directive.accByLuaFile,
        ['VANILLA_WAF'] = Directive.accByLua,
        ['CONTENT_BY_LUA'] = Directive.contentByLua,
        ['CONTENT_BY_LUA_FILE'] = Directive.contentByLuaFile,
        ['PORT'] = 80,
        ['LUA_PACKAGE_PATH'] = Directive.luaPackagePath,
        ['LUA_PACKAGE_CPATH'] = Directive.luaPackageCpath
    }
end

return Directive