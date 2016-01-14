-- perf
local error = error
local ngxmatch=ngx.re.gmatch

-- init RestFul and set routes
local RestFul = {}

function RestFul:new(request)
    local instance = {
        route_name = 'vanilla.v.routes.restful',
    	request = request
    }

    setmetatable(instance, {
        __index = self,
        __tostring = function(self) return self.route_name end
        })
    return instance
end

function RestFul:match()
    local rules = require 'config.restful'
    -- print_r(rules)
    local uri = self.request.uri
    local match = {}
    local tmp = 1
    if uri == '/' then
        return 'index', 'index'
    end
    for v in ngxmatch(uri , '/([A-Za-z0-9_]+)') do
        match[tmp] = v[1]
        tmp = tmp +1
    end
    if #match == 1 then
        return match[1], 'index'
    else
        return table.concat(match, '.', 1, #match - 1), match[#match]
    end
end

return RestFul