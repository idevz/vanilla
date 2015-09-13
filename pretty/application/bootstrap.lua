local Bootstrap = require('vanilla.v.bootstrap'):new(dispatcher)

function Bootstrap:initConfig()
	-- error({code = 101, msg = {Bootstrap = '----------'}})
	self.zzz = '------------------'
end

function Bootstrap:initPlugin()
	-- ngx.say('-----------initPlugin' .. self.zzz)
	self.zzz = '============'
end

function Bootstrap:initErrorHandle()
	self.dispatcher:setErrorHandler({controller = 'error', action = 'index'})
end

function Bootstrap:initRoute()
	-- ngx.say('-----------initRoute' .. self.zzz)
	local router = require('vanilla.v.routes.simple'):new(self.dispatcher:getRequest())
	self.dispatcher.router = router
end

function Bootstrap:initView()

end

function Bootstrap:boot_list()
	return {
		Bootstrap.initConfig,
		Bootstrap.initPlugin,
		-- Bootstrap.initErrorHandle,
		Bootstrap.initRoute,
		Bootstrap.initView
	}
end

return Bootstrap




