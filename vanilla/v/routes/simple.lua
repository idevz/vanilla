-- init Simple and set routes
local Simple = {}

function Simple.new(...)

    local instance = {
    }

    setmetatable(instance, Simple)
    return instance
end

-- match request to routes
function Simple.match(request)

end

return Simple