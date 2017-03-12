-- perf
local error = error
local ngxgsub = ngx.re.gsub
local ngxmatch = ngx.re.match
local accept_header_pattern = "^application/vnd." .. Registry['APP_NAME'] .. ".v(\\d+)(.*)+json$"
local function tappend(t, v) t[#t+1] = v end

local http_methods = {
    GET = true,
    POST = true,
    HEAD = true,
    OPTIONS = true,
    PUT = true,
    PATCH = true,
    DELETE = true,
    TRACE = true,
    CONNECT = true
}

local function rule_pattern(pattern)
    local params = {}
    local n_p = ngxgsub(pattern, "/:([A-Za-z0-9_]+)", function(m) tappend(params, m[1]); return "/([A-Za-z0-9_]+)" end, "io")
    return n_p, params
end

local function get_rules(request)
    local rules_conf = LoadApp 'config.restful'
    local header_accept = request:getHeader('accept')
    local req_method = request:getMethod()
    local version = ''
    local rules = {}
    if not http_methods[req_method] then error({ code = 201, msg = {Req_Method = 'Request Method Not Allowed...'}}) end
    local v
    if header_accept then v = ngxmatch(header_accept, accept_header_pattern) end
    if v then version = v[1] end
    if rules_conf['v' .. version] ~= nil and rules_conf['v' .. version][req_method] ~= nil then
        for k,info in pairs(rules_conf['v' .. version][req_method]) do
            local pattern, params = rule_pattern(info['pattern'])
            local pattern_reg = "^" .. pattern .. "$"
            rules[k] = info
            rules[k]['pattern_reg'] = pattern_reg
            rules[k]['params'] = params
        end
    -- else
    --     error({ code = 201, msg = {Empty_Rules = 'Null routes rules for this Version Or Method Like:' 
    --         .. 'v' .. version .. '.' .. req_method}})
    end
    return rules
end

local RestFul = {}

function RestFul:new(request)
    local instance = {
        route_name = 'vanilla.v.routes.restful',
        request = request,
        rules = get_rules(request)
    }

    setmetatable(instance, {
        __index = self,
        __tostring = function(self) return self.route_name end
        })
    return instance
end

function RestFul:match()
    local uri = self.request.uri
    local match_rs = nil
    for k,info in pairs(self.rules) do
        match_rs = ngxmatch(uri, info['pattern_reg'], "io")
        if match_rs then
            for index, p in pairs(info['params']) do
                self.request:setParam(p, match_rs[index])
            end
            return info['controller'], info['action']
        end
    end
    if uri == '/' then
        return 'index', 'index'
    end
end

return RestFul
