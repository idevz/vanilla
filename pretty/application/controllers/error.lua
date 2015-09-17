-- local ErrorController = require('vanilla.v.error'):new(code, custom_attrs)
local ErrorController = {}

function ErrorController:error()
	local view = self:getView()
	-- local p = {}
	-- p['message'] = '====cc======'
	-- p['status'] = '=====kk====='
	-- return view:assign(self.err)
	view:assign(self.err)
	return view:display()
	-- return view:assign(p)
end

function ErrorController:index()
	pp(self.err)
	ngx.eof()
end

return ErrorController