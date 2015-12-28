-- perf
local ogetenv = os.getenv


local Sysconf = {}

-- version
Sysconf.version = '0.1.0-rc3'

-- environment
Sysconf.env = ogetenv("VA_ENV") or 'development'

-- directories
Sysconf.app_dirs = {
    tmp = 'tmp',
    logs = 'logs'
}

if Sysconf.env == 'development' or Sysconf.env == 'test' then
    function sprint_r( ... )
        local helpers = require 'vanilla.v.libs.utils'
        return helpers.sprint_r(...)
    end

    function lprint_r( ... )
        local rs = sprint_r(...)
        print(rs)
    end

    function print_r( ... )
        local rs = sprint_r(...)
        ngx.say(rs)
    end

    function err_log(msg)
        ngx.log(ngx.ERR, "===zjdebug" .. msg .. "===")
    end
end

return Sysconf