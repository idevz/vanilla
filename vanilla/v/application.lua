-- perf
local pairs = pairs
local pcall = pcall
local old_require = require
local setmetatable = setmetatable

function require(m_name)
    local DOCUMENT_ROOT = ngx.var.document_root
    -- 'config or' for busted test
    local config = config or old_require(DOCUMENT_ROOT .. '/config.application')
    local VANILLA_VERSION = config.vanilla_version
    local VANILLA_ROOT = config.vanilla_root

    local va_m_name = VANILLA_VERSION .. '/' .. m_name
    local va_name_no_va_m_name = VANILLA_VERSION .. '/vanilla/' .. m_name
    local app_m_name = DOCUMENT_ROOT .. '/' .. m_name
    local app_application_m_name = DOCUMENT_ROOT .. '/application/' .. m_name
    local app_library_m_name = DOCUMENT_ROOT .. '/application/library/' .. m_name

    if package.loaded[va_m_name] then return package.loaded[va_m_name]
    elseif package.loaded[va_name_no_va_m_name] then return package.loaded[va_name_no_va_m_name]
    elseif package.loaded[app_m_name] then return package.loaded[app_m_name]
    elseif package.loaded[app_application_m_name] then return package.loaded[app_application_m_name]
    elseif package.loaded[app_library_m_name] then return package.loaded[app_library_m_name]
    elseif package.loaded[m_name] then return package.loaded[m_name] end
    -- ngx.say(m_name .. '<br />')

    local vanilla_module_name
    local vanilla_framework_path = VANILLA_ROOT .. '/?.lua;' .. VANILLA_ROOT .. '/?/init.lua'
    if package.searchpath(va_m_name, vanilla_framework_path) ~=nil then
        vanilla_module_name = va_m_name
    elseif package.searchpath(va_name_no_va_m_name, vanilla_framework_path) ~=nil then
        vanilla_module_name = va_name_no_va_m_name
    elseif package.searchpath(app_m_name, '/?.lua;/?/init.lua') ~=nil then
        vanilla_module_name = app_m_name
    elseif package.searchpath(app_application_m_name, '/?.lua;/?/init.lua') ~=nil then
        vanilla_module_name = app_application_m_name
    elseif package.searchpath(app_library_m_name, '/?.lua;/?/init.lua') ~=nil then
        vanilla_module_name = app_library_m_name
    else
        vanilla_module_name = m_name
    end
    -- ngx.say(vanilla_module_name .. '<br />')
    return old_require(vanilla_module_name)
end

-- vanilla
local Error = require 'vanilla.v.error'
local Dispatcher = require 'vanilla.v.dispatcher'
local Registry = require('vanilla.v.registry'):new('sys')
local Utils = require 'vanilla.v.libs.utils'

local function new_dispatcher(self)
    return Dispatcher:new(self)
end

local function new_bootstrap_instance(lbootstrap, dispatcher)
    return require(lbootstrap):new(dispatcher)
end

local Application = {}

function Application:lpcall( ... )
    local ok, rs_or_error = pcall( ... )
    if ok then
        return rs_or_error
    else
        self:raise_syserror(rs_or_error)
    end
end

function Application:buildconf(config)
    local sys_conf = require 'vanilla.sys.config'
    if config ~= nil then
        for k,v in pairs(config) do sys_conf[k] = v end
    end
    if sys_conf.name == nil or sys_conf.app.root == nil then
        self:raise_syserror([[
            Sys Err: Please set app name and app root in config/application.lua like:
            
                Appconf.name = 'idevz.org'
                Appconf.app.root='./'
            ]])
    end
    Registry['app_name'] = sys_conf.name
    Registry['app_root'] = sys_conf.app.root
    Registry['app_version'] = sys_conf.version
    self.config = sys_conf
    return true
end

function Application:new(config)
    self:buildconf(config)
    local instance = {
        dispatcher = self:lpcall(new_dispatcher, self)
    }
    setmetatable(instance, {__index = self})
    return instance
end

function Application:bootstrap()
    local lbootstrap = 'application.bootstrap'
    if self.config['bootstrap'] ~= nil then
        lbootstrap = self.config['bootstrap']
    end
    bootstrap_instance = self:lpcall(new_bootstrap_instance, lbootstrap, self.dispatcher)
    self:lpcall(bootstrap_instance.bootstrap, bootstrap_instance)
    return self
end

function Application:run()
    self:lpcall(self.dispatcher.dispatch, self.dispatcher)
end

function Application:raise_syserror(err)
    if type(err) == 'table' then
        err = Error:new(err.code, err.msg)
        ngx.status = err.status
    else
        ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
    end
    ngx.say('<pre />')
    ngx.say(Utils.sprint_r(err))
    ngx.eof()
end

return Application