local Bootstrap = require('vanilla.v.bootstrap'):new(dispatcher)

function Bootstrap:initConfig()
	self.zzz = '------------------'
end

function Bootstrap:initPlugin()
	ngx.say('-----------initPlugin' .. self.zzz)
	self.zzz = '============'
end

function Bootstrap:initRoute()
	ngx.say('-----------initRoute' .. self.zzz)
	local route = require('vanilla.v.routes.simple'):new(self.dispatcher:getRequest())
	self.dispatcher.route = route
end

function Bootstrap:initView()

end

function Bootstrap:boot_list()
	return {
		Bootstrap.initConfig,
		Bootstrap.initPlugin,
		Bootstrap.initRoute,
		Bootstrap.initView
	}
end

return Bootstrap




