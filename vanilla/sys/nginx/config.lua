-- perf
local ogetenv = os.getenv

local init_by_lua = [[
lua_package_path '/usr/local/luarocks-2.2.2/share/lua/5.1/?.lua;/usr/local/luarocks-2.2.2/share/lua/5.1/?/init.lua;/Users/zjngx/ngx_lua/?.lua;/Users/sinacode/keepmoving/falcon/trunk/ngx/lib/?.lua;;';
lua_package_cpath '/usr/local/luarocks-2.2.2/lib/lua/5.1/?.so;/Users/zjngx/ngx_lua_c/?.so;/Users/sinacode/keepmoving/falcon/trunk/ngx/lib/?.so;;';
lua_code_cache off;
lua_shared_dict falcon_share 100m;
init_by_lua_file /Users/sinacode/keepmoving/falcon/trunk/ngx/app/init.lua;
access_by_lua_file /Users/sinacode/keepmoving/falcon/trunk/ngx/app/acc.lua;
]]

local NgxConf = {}

-- environment
NgxConf.env = ogetenv("VA_ENV") or 'development'

-- directories
NgxConf.directives = {
	['INIT_BY_LUA'] = init_by_lua,
}

NgxConf.settings = settings.for_environment(NgxConf.env)

return NgxConf
