local helpers = require 'gin.helpers.common'
local ErrorController = require('vanilla.v.error'):new(code, custom_attrs)

function ErrorController:error()
	local view = self:getView()
	-- view:render('index/index.html', {message = '============'})
	-- pp(view:caching(true))
	local resp = self:getResponse()
	-- resp:setHeader('Content_type', 'application/json')
	view:assign('message', '-----TTTT------')
	view:assign('kk', '------Index-----')
	-- view:assign()
	view:display()
	-- return 200, { message = "-------!" .. self.params.p }
end

return ErrorController