local Bootstrap = require('vanilla.v.bootstrap'):new(dispatcher)

function Bootstrap:initConfig()

end

function Bootstrap:initPlugin()
	ngx.say('-----------initPlugin')
end

function Bootstrap:initRoute()
	ngx.say('-----------initRoute')
	local route = require('vanilla.v.routes.simple'):new(self.dispatcher:getRequest())
	self.dispatcher.route = route
	pp(self.dispatcher)
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




