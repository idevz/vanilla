package.loaded['config.routes'] = { }
package.loaded['config.application'] = {}

_G['ngx'] = {
    HTTP_NOT_FOUND = 404,
    exit = function(code) return end,
    print = function(print) return end,
    status = 200,
    location = {},
    say = print,
    eof = os.exit,
    header = {},
    re = {
        gmatch = function() return end,
    },
    req = {
        read_body = function() return end,
        get_body_data = function() return end,
        get_headers = function() return end,
        get_uri_args = function() return {} end,
        get_method = function() return {} end,
        get_post_args = function() return {busted = 'busted'} end,
    },
    var = {
        uri = "/users",
        request_method = 'GET'
    }
}

local config={}
config.name = 'bluebird'

config.route='vanilla.v.routes.simple'
config.bootstrap='application.bootstrap'
config.app={}
config.app.root='./'

config.controller={}
config.controller.path=config.app.root .. 'application/controllers/'

config.view={}
config.view.path=config.app.root .. 'application/views/'
config.view.suffix='.html'
config.view.auto_render=true

_G['config'] = config

require 'vanilla.spec.runner'