local helpers = require 'gin.helpers.common'
local TController = {}

function TController:index()
	local view = self:getView()
	-- view:render('index/index.html', {message = '============'})
	-- pp(view:caching(true))
	-- local resp = self:getResponse()
	-- resp:clearHeaders()
	-- resp:setHeader('Content_type', 'application/json')
	local p = {}
	p['message'] = '====cc======'
	p['kk'] = '=====kk====='
	-- view:assign('message', '-----TTTT------')
	-- view:assign('kk', '------Index-----')
	return view:assign(p)
	-- view:display()
	-- return 200, { message = "-------!" .. self.params.p }
end

function TController:aa()
	local view = self:getView()
	-- view:render('index/index.html', {message = '============'})
	-- pp(view:caching(true))
	local resp = self:getResponse()
	-- resp:setHeader('Content_type', 'application/json')
	-- pp(self.params)
	-- pp(self.request)
	view:assign('message', '-----TTTT------')
	view:assign('kk', '------Aa-----' .. self.params['c'])
	-- view:assign()
	view:display()
	-- return 200, { message = "-------!" .. self.params.p }
end

return TController