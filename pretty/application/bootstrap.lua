local Bootstrap = require('vanilla.v.bootstrap'):new(dispatcher)

function Bootstrap:initConfig()

end

function Bootstrap:initPlugin()

end

function Bootstrap:initRoute()
	-- pp(self)
	local route = require('vanilla.v.routes.simple'):new(self.dispatcher.getRequest())
	self.dispatcher.route = route
end

function Bootstrap:initView()

end

function Bootstrap:bootList()
	return {
		Bootstrap:initConfig(),
		Bootstrap:initPlugin(),
		Bootstrap:initRoute(),
		Bootstrap:initView()
	}
end

return Bootstrap




