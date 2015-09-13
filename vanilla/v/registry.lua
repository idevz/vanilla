-- perf
local setmetatable = setmetatable

local Registry = {}

function Registry:del(key)
    ngx.vanilla_userdata[self.namespace][key] = nil
end

function Registry:get(key)
    if ngx.vanilla_userdata[self.namespace][key] ~= nil then
        return ngx.vanilla_userdata[self.namespace][key]
    else
        return false
    end
end

function Registry:has(key)
    if ngx.vanilla_userdata[self.namespace][key] ~= nil then
        return true 
    else
        return false
    end
end

function Registry:set(key, value)
    ngx.vanilla_userdata[self.namespace][key] = value
    return true
end

function Registry:dump(namespace)
    local rs = {}
    if namespace ~= nil then
        rs = ngx.vanilla_userdata[namespace]
    else
        rs = ngx.vanilla_userdata
    end
    return rs
end

function Registry:new(namespace)
    if ngx.vanilla_userdata == nil then ngx.vanilla_userdata= {} end
    if namespace == nil then namespace = 'default' end
    if ngx.vanilla_userdata[namespace] == nil then ngx.vanilla_userdata[namespace] = {} end
    local instance = {
        namespace = namespace,
        del = self.del,
        get = self.get,
        has = self.has,
        dump = self.dump,
        set = self.set,
        __cache = {}
    }
    setmetatable(instance, Registry)
    return instance
end

function Registry:__index(index)
    local out = rawget(rawget(self, '__cache'), index)
    if out then return out end
end

return Registry