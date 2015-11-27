-- vanilla
local helpers = require 'vanilla.v.libs.utils'

-- ensure test environment is specified
local posix = require "posix"
posix.setenv("VA_ENV", 'test')

function pp( ... )
    local s = helpers.pps(...)
    print(s)
end