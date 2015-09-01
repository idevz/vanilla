-- perf
local setmetatable = setmetatable


local Response = {}
Response.__index = Response

function Response.new(options)
    options = options or {}

    local instance = {
        status = options.status or 200,
        headers = options.headers or {},
        body = options.body or {},
    }
    setmetatable(instance, Response)
    return instance
end

function Response:appendBody()
end

function Response:clearBody()
end

function Response:clearHeaders()
end

function Response:__clone()
end

function Response:__construct()
end

function Response:__destruct()
end

function Response:getBody()
end

function Response:getHeader()
end

function Response:prependBody()
end

function Response:response()
end

function Response:setAllHeaders()
end

function Response:setBody()
end

function Response:setHeader()
end

function Response:setRedirect()
end

function Response:__toString ()
end

return Response
