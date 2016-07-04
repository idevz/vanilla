-- Config Parse moudle
-- @since 2016-05-8 8:54
-- @author idevz <zhoujing00k@gmail.com>
-- version $Id$

local Parse = {}

function Parse.ini(lines, name)
    local t = {}
    local section
    for line in lines(name) do
        local s = line:match("^%[([^%]]+)%]$")
        if s then
            section = s
            t[section] = t[section] or {}
            goto CONTINUE
        end
        local key, value = line:match("^(%w+)%s-=%s-(.+)$")
        if key and value then
            if tonumber(value) then value = tonumber(value) end
            if value == "true" then value = true end
            if value == "false" then value = false end
            t[section][key] = value
        end
        ::CONTINUE::
    end
    return t
end

return Parse


-- Config Parse moudle
-- @since 2016-05-8 8:54
-- @author idevz <zhoujing00k@gmail.com>
-- version $Id$

-- local Parse = {}
-- local ngx_re_match = ngx.re.match

-- function Parse.ini(lines, name)
--     local t = {}
--     local section
--     for line in lines(name) do
--         local s = ngx_re_match(line, [[^\[(.*)\]$]], 'o')
--         if s then
--             section = s[1]
--             t[section] = t[section] or {}
--             goto CONTINUE
--         end
--         local s_conf = ngx_re_match(line, [[^(\w+)\s*=\s*(.*)$]], 'o')
--         local key, value
--         if s_conf then
--             local key, value = s_conf[1], s_conf[2]
--             if key and value then
--                 if tonumber(value) then value = tonumber(value) end
--                 if value == "true" then value = true end
--                 if value == "false" then value = false end
--                 t[section][key] = value
--             end
--         end
--         -- local key, value = ngx_re_match(line, [[^(\w+)\s*=\s*(.*)$]], 'o')
--         ::CONTINUE::
--     end
--     return t
-- end

-- return Parse
