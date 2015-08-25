package.path = './app/controllers/?.lua;' .. package.path

-- dep
local json = require 'cjson'

-- vanilla
local Controller = require 'vanilla.v.controller'
local Request = require 'vanilla.v.request'
local Response = require 'vanilla.v.response'
local Error = require 'vanilla.v.error'

-- app
-- local Routes = require 'config.routes'
-- local Application = require 'config.application'

-- perf
local error = error
local jencode = json.encode
local pairs = pairs
local pcall = pcall
local require = require
local setmetatable = setmetatable
local smatch = string.match
local function tappend(t, v) t[#t+1] = v end


-- init Application and set routes
local Application = {}

function Application.new(ngx, config)
    if config then
        local config = config
    else
        local config = require('vanilla.v.config')
    end
    
    local instance = {
        ngx = ngx,
        run = Application.run,
        config = config
    }

    setmetatable(instance, Application)
    return instance
end

function Application:run()
    ngx.say('==================----------=======')
end

return Application