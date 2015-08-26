local Bootstrap = require('vanilla.v.bootstrap'):new(dispatcher)

function Bootstrap:initConfig()

end

function Bootstrap:initPlugin()

end

function Bootstrap:initRoute()
	-- local route = require('')
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




