-- vanilla
local settings = require 'vanilla.v.config'

-- perf
local ogetenv = os.getenv


local V = {}

-- version
V.version = '0.1.5'

-- environment
V.env = ogetenv("GIN_ENV") or 'development'

-- directories
V.app_dirs = {
    tmp = 'tmp',
    logs = 'logs',
    db = 'db',
    schemas = 'db/schemas',
    migrations = 'db/migrations'
}

V.settings = settings.for_environment(V.env)

function pp( ... )
	local helpers = require 'gin.helpers.common'
	helpers.pp(...)
	helpers.pp_to_file(..., '/Users/zj-gin/sina/zj')
end
return V