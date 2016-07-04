-- Config Save moudle
-- @since 2016-05-8 8:54
-- @author idevz <zhoujing00k@gmail.com>
-- version $Id$

local Save = {}

function Save.ini(write, name, t)
    local contents = ""
    for section, s in pairs(t) do
        contents = contents .. ("[%s]\n"):format(section)
        for key, value in pairs(s) do
            contents = contents .. ("%s=%s\n"):format(key, tostring(value))
        end
        contents = contents .. "\n"
    end
    write(name, contents)
end

return Save
