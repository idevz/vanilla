-- vanilla
local settings = require 'vanilla.sys.env'

-- perf
local ogetenv = os.getenv


local Sysconf = {}

-- version
Sysconf.version = '0.0.1'

-- environment
Sysconf.env = ogetenv("VA_ENV") or 'development'

-- directories
Sysconf.app_dirs = {
    tmp = 'tmp',
    logs = 'logs'
}

Sysconf.settings = settings.for_environment(Sysconf.env)

return Sysconf
