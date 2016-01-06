-- vanilla
local helpers = require 'vanilla.v.libs.utils'

-- ensure test environment is specified
VA_ENV = 'test'
local posix = require "posix"
posix.setenv("VA_ENV", 'test')