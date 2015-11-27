-- perf
local ogetenv = os.getenv


local Sysconf = {}

-- version
Sysconf.version = '0.1.0-rc2'

-- environment
Sysconf.env = ogetenv("VA_ENV") or 'development'

-- directories
Sysconf.app_dirs = {
    tmp = 'tmp',
    logs = 'logs'
}

-- ngx.say(Sysconf.env)

if Sysconf.env == 'development' then
    function pps( ... )
        local helpers = require 'vanilla.v.libs.utils'
        return helpers.pps(...)
    end

    function ppl( ... )
        local rs = pps(...)
        print(rs)
    end

    function pp( ... )
        local rs = pps(...)
        ngx.say(rs)
    end

    function err_log(msg)
        ngx.log(ngx.ERR, "===zjdebug" .. msg .. "===")
    end
end

return Sysconf