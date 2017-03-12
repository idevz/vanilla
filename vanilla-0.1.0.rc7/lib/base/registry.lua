-- Vanilla Registry
-- @since 2016-04-09 20:34
-- @author idevz <zhoujing00k@gmail.com>
-- version $Id$

local setmetatable = setmetatable

local Registry = {}

function Registry:del(key)
    VANILLA_REGISTRY[self.namespace][key] = nil
    return true
end

function Registry:get(key)
    if VANILLA_REGISTRY[self.namespace][key] ~= nil then
        return VANILLA_REGISTRY[self.namespace][key]
    else
        return false
    end
end

function Registry:has(key)
    if VANILLA_REGISTRY[self.namespace][key] ~= nil then
        return true 
    else
        return false
    end
end

function Registry:set(key, value)
    VANILLA_REGISTRY[self.namespace][key] = value
    return true
end

function Registry:dump(namespace)
    if namespace ~= nil then return VANILLA_REGISTRY[namespace] else return VANILLA_REGISTRY end
end

function Registry:new()
    local instance = {
        namespace = 'vanilla_app',
        del = self.del,
        get = self.get,
        has = self.has,
        dump = self.dump,
        set = self.set
    }
    setmetatable(instance, Registry)
    return instance
end

function Registry:__newindex(index, value)
    -- ngx.say('----__newindex----')
    if VANILLA_REGISTRY[self.namespace] == nil then VANILLA_REGISTRY[self.namespace] = {} end
    if index ~= nil then
        VANILLA_REGISTRY[self.namespace][index]=value
    end
end

function Registry:__index(index)
    -- ngx.say('----__index----')
    if VANILLA_REGISTRY[self.namespace] == nil then VANILLA_REGISTRY[self.namespace] = {} end
    local out = rawget(VANILLA_REGISTRY[self.namespace], index)
    if out then return out else return false end
end

return Registry