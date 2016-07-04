-- vanilla
local helpers = require 'vanilla.v.libs.utils'

-- ensure test environment is specified
VA_ENV = 'test'
-- getOsEnv through nginx config file
local posix = require "posix"
posix.setenv("VA_ENV", 'test')