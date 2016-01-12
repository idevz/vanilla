-- vanilla
local helpers = require 'vanilla.v.libs.utils'

-- perf
local pairs = pairs
local ogetenv = os.getenv
local app_run_evn = ogetenv("VA_ENV") or 'development'

local va_ngx_conf = {}
va_ngx_conf.common = {
	VA_ENV = app_run_evn,
}

if VANILLA_NGX_PATH ~= nil then
	va_ngx_conf.common.NGX_PATH = VANILLA_NGX_PATH
end

va_ngx_conf.env = {}
va_ngx_conf.env.development = {
    LUA_CODE_CACHE = false,
    PORT = 9110
}

va_ngx_conf.env.test = {
    LUA_CODE_CACHE = true,
    PORT = 9111
}

va_ngx_conf.env.production = {
    LUA_CODE_CACHE = true,
    PORT = 80
}

local function getNgxConf(conf_arr)
	if conf_arr['common'] ~= nil then
		local common_conf = conf_arr['common']
		if common_conf['BASE_LIBRARY'] ~= nil then 
			package.path = package.path .. ';' .. common_conf['BASE_LIBRARY'] .. '/?.lua;'
						   .. common_conf['BASE_LIBRARY'] .. '/?/init.lua'
			package.cpath = package.cpath .. ';' .. common_conf['BASE_LIBRARY'] .. '/?.so'
		end
		local env_conf = conf_arr['env'][app_run_evn]
		for directive, info in pairs(common_conf) do
			env_conf[directive] = info
		end
		return env_conf
	elseif conf_arr['env'] ~= nil then
		return conf_arr['env'][app_run_evn]
	end
	return {}
end

local function buildConf()
	local get_app_va_ngx_conf = helpers.try_require('config.nginx', {})
	local app_ngx_conf = getNgxConf(get_app_va_ngx_conf)
	local sys_ngx_conf = getNgxConf(va_ngx_conf)
	if app_ngx_conf ~= nil then
		for k,v in pairs(app_ngx_conf) do
			sys_ngx_conf[k] = v
		end
	end
	return sys_ngx_conf
end

local ngx_directive_handle = require('vanilla.sys.nginx.directive'):new(app_run_evn)
local ngx_directives = ngx_directive_handle:directiveSets()

local VaNgxConf = {}

local ngx_run_conf = buildConf()

for directive, func in pairs(ngx_directives) do
	if type(func) == 'function' then
		local func_rs = func(ngx_directive_handle, ngx_run_conf[directive])
		if func_rs ~= false then
			VaNgxConf[directive] = func_rs
		end
	else
		VaNgxConf[directive] = ngx_run_conf[directive]
	end
end

return VaNgxConf