-- perf
local setmetatable = setmetatable

local vanilla_userdata = {}

local Registry = {}

function Registry:del(key)
    vanilla_userdata[self.namespace][key] = nil
end

function Registry:get(key)
    if vanilla_userdata[self.namespace][key] ~= nil then
        return vanilla_userdata[self.namespace][key]
    else
        return false
    end
end

function Registry:has(key)
    if vanilla_userdata[self.namespace][key] ~= nil then
        return true 
    else
        return false
    end
end

function Registry:set(key, value)
    vanilla_userdata[self.namespace][key] = value
    return true
end

function Registry:dump(namespace)
    local rs = {}
    if namespace ~= nil then
        rs = vanilla_userdata[namespace]
    else
        rs = vanilla_userdata
    end
    return rs
end

function Registry:new(namespace)
    if namespace == nil then namespace = 'default' end
    if vanilla_userdata[namespace] == nil then vanilla_userdata[namespace] = {} end
    local instance = {
        namespace = namespace,
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
    if index ~=nil and value ~= nil then
        vanilla_userdata[self.namespace][index]=value
    end
end

function Registry:__index(index)
    local out = rawget(vanilla_userdata[self.namespace], index)
    if out then return out else return false end
end

return Registry