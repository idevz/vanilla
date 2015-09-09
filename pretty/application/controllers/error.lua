-- local ErrorController = require('vanilla.v.error'):new(code, custom_attrs)
local ErrorController = {}
local helpers = require 'gin.helpers.common'

function ErrorController:error()
	local view = self:getView()
	-- local p = {}
	-- p['message'] = '====cc======'
	-- p['status'] = '=====kk====='
	return view:assign(self.err)
	-- return view:assign(p)
end

function ErrorController:index()
	local view = self:getView()
	local p = {}
	p['message'] = '====cc======'
	p['kk'] = '=====kk====='
	return view:assign(p)
	-- return 200, { message = "-------!" .. self.params.p }
end

return ErrorController