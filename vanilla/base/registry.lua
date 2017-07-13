-- Vanilla Registry
-- @since 2016-04-09 20:34
-- @author idevz <zhoujing00k@gmail.com>
-- version $Id$

local ok, new_tab = pcall(require, "table.new")
if not ok or type(new_tab) ~= "function" then
    new_tab = function (narr, nrec) return {} end
end

local setmetatable = setmetatable

local Registry = new_tab(0, 6)

function Registry:del(key)
    local data = rawget(self, "_data")
    if data[self.namespace] ~= nil and data[self.namespace][key] ~= nil then
        data[self.namespace][key] = nil
    end
    return true
end

function Registry:has(key)
    local data = rawget(self, "_data")
    if data[self.namespace][key] ~= nil then
        return true
    else
        return false
    end
end

function Registry:dump(namespace)
    local data = rawget(self, "_data")
    if namespace ~= nil then return data[namespace] else return data end
end

function Registry:new()
    local data = new_tab(0, 36)
    local instance = {
        namespace = 'vanilla_app',
        del = self.del,
        has = self.has,
        dump = self.dump,
        _data = data
    }
    return setmetatable(instance, {__index = self.__index, __newindex = self.__newindex})
end

function Registry:__newindex(index, value)
    local data = rawget(self, "_data")
    if data[self.namespace] == nil then data[self.namespace] = {} end
    if index ~= nil then
        data[self.namespace][index]=value
    end
end

function Registry:__index(index)
    local data = rawget(self, "_data")
    if data[self.namespace] == nil then data[self.namespace] = {} end
    local out = data[self.namespace][index]
    if out then return out else return false end
end

return Registry
