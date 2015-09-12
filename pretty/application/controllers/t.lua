local helpers = require 'gin.helpers.common'
local TController = {}

function TController:index()
	 -- error({ code = 100})
	local view = self:getView()
	-- view:render('index/index.html', {message = '============'})
	-- pp(view:caching(true))
	-- local resp = self:getResponse()
	-- resp:clearHeaders()
	-- resp:setHeader('Content_type', 'application/json')
	local r = require('vanilla.v.registry'):new('zj')
	local rs = '-'
	rs = r:get('zhou')
	local p = {}
	p['message'] = '====ccc======' .. rs
	p['kk'] = '=====kk=====' .. pps(r)
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