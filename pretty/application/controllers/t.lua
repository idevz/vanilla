local helpers = require 'gin.helpers.common'
local TController = {}

function TController:index()
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

function TController:aa()
	local view = self:getView()
	-- view:render('index/index.html', {message = '============'})
	-- pp(view:caching(true))
	local resp = self:getResponse()
	-- resp:setHeader('Content_type', 'application/json')
	pp(self.params)
	-- pp(self.request)
	view:assign('message', '-----TTTT------')
	view:assign('kk', '------Aa-----' .. self.params['c'])
	-- view:assign()
	view:display()
	-- return 200, { message = "-------!" .. self.params.p }
end

return TController