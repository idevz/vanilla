-- Request moudle
-- @since 2015-08-17 10:54
-- @author idevz <zhoujing00k@gmail.com>
-- version $Id$

VANILLA_G = _G
VANILLA_REGISTRY = {}
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

local old_require = require
require = function( ... )
    ngx.say(...)
    return old_require(...)
end


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
        for _,v in ipairs(sysconf_files) do
            Registry[v] = conf_handle:get('sys/' .. v)
        end
end


--+--------------------------------------------------------------------------------+--
init_vanilla = function ()
    Registry.namespace = ngx.var.APP_NAME
    if Registry['VANILLA_INIT'] then return end
    Registry['VA_ENV'] = ngx.var.VA_ENV
    Registry['APP_NAME'] = Registry.namespace
    Registry['APP_ROOT'] = ngx.var.document_root
    Registry['APP_HOST'] = ngx.var.host
    Registry['APP_PORT'] = ngx.var.server_port
    Registry['VANILLA_ROOT'] = ngx.var.VANILLA_ROOT
    Registry['VANILLA_VERSION'] = ngx.var.VANILLA_VERSION
    Registry['APP_CONF'] = LoadApp 'config.application'
    Registry['VANILLA_APPLICATION'] = LoadV 'vanilla.v.application'
    Registry['APP_BOOTS'] = LoadApp 'application.bootstrap'
    LoadSysConf()
    Registry['VANILLA_INIT'] = true
end


--+--------------------------------------------------------------------------------+--