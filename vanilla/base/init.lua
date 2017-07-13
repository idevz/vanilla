-- Request moudle
-- @since 2015-08-17 10:54
-- @author idevz <zhoujing00k@gmail.com>
-- version $Id$


-- local helpers = require '/media/psf/g/idevz/code/www/vanilla/framework/0_1_0_rc7/vanilla.v.libs.utils'
-- function sprint_r( ... )
--     return helpers.sprint_r(...)
-- end

-- function lprint_r( ... )
--     local rs = sprint_r(...)
--     print(rs)
-- end

-- function print_r( ... )
--     local rs = sprint_r(...)
--     ngx.say(rs)
-- end

Registry = require('registry'):new()


--+--------------------------------------------------------------------------------+--
local _class = function(_, classname, parent)
    local mttt = {
        __call = function(self, ... )
            return self:new(...)
        end
    }
    local parent_type = type(parent)
    if parent_type ~= "function" and parent_type ~= "table" then
        parent = nil
    end
    local cls = {}
    if parent then
        mttt.__index = parent
        cls.parent = parent
    end
    cls.new = function(self, ...)
        local instance = { class = self }
        setmetatable(instance, self)
        if instance.__construct and type(instance.__construct) == 'function' then
            instance:__construct(...)
        end
        return instance
    end
    cls["is" .. classname]  =true
    cls.__cname = classname
    cls.__index = cls
    setmetatable(cls, mttt)
    return cls
end

local class = {}
Class = setmetatable(class, { __call = function(...) return _class(...) end })

-- local old_require = require
-- require = function( ... )
--     -- ngx.say(...)
--     return old_require(...)
-- end


--+--------------------------------------------------------------------------------+--
local require = require
LoadLibrary = function ( ... )
    return require(Registry['APP_ROOT'] .. '/application/library/' .. ...)
end

LoadController = function ( ... )
    return require(Registry['APP_ROOT'] .. '/application/controllers/' .. ...)
end

LoadModel = function ( ... )
    return require(Registry['APP_ROOT'] .. '/application/models/' .. ...)
end

LoadPlugin = function ( ... )
    return require(Registry['APP_ROOT'] .. '/application/plugins/' .. ...)
end

LoadApplication = function ( ... )
    return require(Registry['APP_ROOT'] .. '/application/' .. ...)
end

LoadApp = function ( ... )
    return require(Registry['APP_ROOT'] .. '/' .. ...)
end

LoadV = function ( ... )
    return require(Registry['VANILLA_ROOT'] .. '/' .. Registry['VANILLA_VERSION'] .. '/' .. ...)
end


--+--------------------------------------------------------------------------------+--
local LoadSysConf = function()
    local sysconf_files = Registry['APP_CONF']['sysconf']
    local conf_handle = LoadV('vanilla.v.config.handle')('ini')
    Registry['sys_conf'] = {}
    for _,v in ipairs(sysconf_files) do
        Registry['sys_conf'][v] = conf_handle:get('sys/' .. v)
    end
end


--+--------------------------------------------------------------------------------+--
init_vanilla = function ()
    local ngx_var = ngx.var
    local ngx_req = ngx.req
    Registry.namespace = ngx_var.APP_NAME

    local REQ_Registry = require('registry'):new()
    REQ_Registry.namespace = ngx_var.APP_NAME

    REQ_Registry['REQ_URI'] = ngx_var.uri
    REQ_Registry['REQ_ARGS'] = ngx_var.args
    REQ_Registry['REQ_ARGS_ARR'] = ngx_req.get_uri_args()
    REQ_Registry['REQ_HEADERS'] = ngx_req.get_headers()
    REQ_Registry['APP_CACHE_PURGE'] = REQ_Registry['REQ_ARGS_ARR']['vapurge']
    ngx.ctx.REQ_Registry = REQ_Registry


    if Registry['VANILLA_INIT'] then return end
    Registry['VA_ENV'] = ngx_var.VA_ENV
    Registry['APP_NAME'] = Registry.namespace
    Registry['APP_ROOT'] = ngx_var.document_root
    Registry['APP_HOST'] = ngx_var.host
    Registry['APP_PORT'] = ngx_var.server_port
    Registry['VANILLA_ROOT'] = ngx_var.VANILLA_ROOT
    Registry['VANILLA_VERSION'] = ngx_var.VANILLA_VERSION

    Registry['VANILLA_APPLICATION'] = LoadV 'vanilla.v.application'
    Registry['VANILLA_UTILS'] = LoadV 'vanilla.v.libs.utils'
    Registry['VANILLA_CACHE_LIB'] = LoadV 'vanilla.v.cache'
    Registry['VANILLA_COOKIE_LIB'] = LoadV 'vanilla.v.libs.cookie'

    Registry['APP_CONF'] = LoadApp 'config.application'
    Registry['APP_BOOTS'] = LoadApp 'application.bootstrap'
    Registry['APP_PAGE_CACHE_CONF'] = Registry['APP_CONF']['page_cache']
    LoadSysConf()
    Registry['VANILLA_INIT'] = true
end

--+--------------------------------------------------------------------------------+--
local ngx_re_find = ngx.re.find
use_page_cache = function ()
    local REQ_Registry = ngx.ctx.REQ_Registry
    local cookie_lib = Registry['VANILLA_COOKIE_LIB']
    local cookie = cookie_lib()
    local no_cache_uris = Registry['APP_PAGE_CACHE_CONF']['no_cache_uris']
    for _, uri in ipairs(no_cache_uris) do
        if ngx_re_find(REQ_Registry['REQ_URI'], uri) ~= nil then return false end
    end
    REQ_Registry['COOKIES'] = cookie:getAll()
    if Registry['APP_PAGE_CACHE_CONF']['cache_on'] then
        if REQ_Registry['COOKIES'] and REQ_Registry['COOKIES'][Registry['APP_PAGE_CACHE_CONF']['no_cache_cookie']] then return false else return true end
    else
        return false
    end
end


--+--------------------------------------------------------------------------------+--
local tab_concat = table.concat
local function clean_args(args)
    local del_keys = Registry['APP_PAGE_CACHE_CONF']['build_cache_key_without_args']
    for _,v in pairs(del_keys) do
        args[v] = nil
    end
    if args['vapurge'] ~= nil then args['vapurge'] = nil end
    return args
end

local function build_url_key(args)
    local rs = {}
    local tmp = 1
    for k,v in pairs(args) do
        rs[tmp] = k .. '=' .. tostring(v)
        tmp = tmp + 1
    end
    return tab_concat( rs, "_")
end

page_cache = function ()
    local ngx_var = ngx.var
    local REQ_Registry = ngx.ctx.REQ_Registry
    REQ_Registry['USE_PAGE_CACHE'] = use_page_cache()
    if not REQ_Registry['USE_PAGE_CACHE'] then ngx.header['X-Cache'] = 'PASSBY' return end
    local cache_lib = Registry['VANILLA_CACHE_LIB']
    Registry['page_cache_handle'] = Registry['APP_PAGE_CACHE_CONF']['cache_handle'] or 'shared_dict'
    local cache = cache_lib(Registry['page_cache_handle'])
    REQ_Registry['APP_PAGE_CACHE_KEY'] = REQ_Registry['REQ_URI'] .. ngx.encode_args(clean_args(REQ_Registry['REQ_ARGS_ARR']))

    if REQ_Registry['APP_CACHE_PURGE'] then
        cache:del(REQ_Registry['APP_PAGE_CACHE_KEY'])
        ngx.header['X-Cache'] = 'XX'
        return 
    end
    
    local rs = cache:get(REQ_Registry['APP_PAGE_CACHE_KEY'])
    if rs then
        ngx.header['X-Cache'] = 'HIT'
        ngx_var.va_cache_status = 'HIT'
        ngx.header['Power_By'] = 'Vanilla-Page-Cache'
        if ngx_re_find(REQ_Registry['REQ_HEADERS']['accept'], 'json') then
            ngx.header['Content_type'] = 'application/json'
        else
            ngx.header['Content_type'] = 'text/html'
        end
        ngx.print(rs)
        ngx.exit(ngx.HTTP_OK)
    else
        ngx.header['X-Cache'] = 'MISS'
        ngx_var.va_cache_status = 'MISS'
    end
end


--+--------------------------------------------------------------------------------+--
