-- perf
local setmetatable = setmetatable


local Response = {}
Response.__index = Response

function Response:new(ngx)
	ngx.header['Content_type'] = 'text/html; charset=UTF-8'
    local instance = {
    	ngx = ngx,
        status = 200,
        headers = {},
        body = {},
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

function Response:getBody()
end

function Response:getHeader()
end

function Response:prependBody()
end

function Response:response()
	self.ngx.send_headers()
end

function Response:setAllHeaders()
end

function Response:setBody()
end

function Response:setHeader(key, value)
	self.ngx.header[key] = value
end

function Response:setRedirect()
end

return Response
