function pps( ... )
    local helpers = require 'vanilla.v.libs.utils'
    return helpers.pps(...)
end

function pp( ... )
    local helpers = require 'vanilla.v.libs.utils'
    -- helpers.pp(...)
    -- helpers.pp_to_file(..., '/Users/zj-git/vanilla/pretty/zj')
    local s = helpers.pps(...)
    -- local s = pps(...)
    print(s)
end

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
return Sysconf