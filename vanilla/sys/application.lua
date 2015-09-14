-- dep
local ansicolors = require 'ansicolors'

-- vanilla
local va_conf = require 'vanilla.sys.config'
local helpers = require 'vanilla.v.libs.utils'


local gitignore = [[
# vanilla
client_body_temp
fastcgi_temp
logs
proxy_temp
tmp
uwsgi_temp

# vim
.*.sw[a-z]
*.un~
Session.vim

# textmate
*.tmproj
*.tmproject
tmtags

# OSX
.DS_Store
._*
.Spotlight-V100
.Trashes
*.swp
]]


local index_controller = [[
local IndexController = {}

function IndexController:index()
    local view = self:getView()
    local req = self:getRequest()
    local p = {}
    p['message'] = 'K'
    p['kk'] = tservice:get()
    view:assign(p)
    view:assign('zhou', 'jing')
    return view:display()
    -- return view:render('t/aa.html', p)
end

return IndexController
]]


local index_tpl = [[
<!DOCTYPE html>
<html>
<body>
  <h1>{{message}}</h1>
  <h1>{{kk}}</h1>
  <h5>{{zhou}}</h5>
</body>
</html>
]]


local error_controller = [[
local ErrorController = {}

function ErrorController:error()
    local view = self:getView()
    view:assign(self.err)
    return view:display()
end

return ErrorController
]]


local error_tpl = [[
<!DOCTYPE html>
<html>
<body>
  <h1>{{status}}</h1>
  {% for k, v in pairs(body) do %}
      {% if k == 'message' then %}
      <h4>{{k}}  =>  {{v}}</h4>
      {% else %}
      <h5>{{k}}  :  {{v}}</h5>
      {% end %}
  {% end %}
</body>
</html>
]]

local dao = [[
-- local TableDao = require('vanilla.v.model.dao'):new()
local TableDao = {}

function TableDao:set(key, value)
    self.__cache[key] = value
    return true
end

function TableDao:new()
    local instance = {
        set = self.set,
        __cache = {}
    }
    setmetatable(instance, TableDao)
    return instance
end

function TableDao:__index(key)
    local out = rawget(rawget(self, '__cache'), key)
    if out then return out else return false end
end
return TableDao
]]

local service = [[
-- local UserService = require('vanilla.v.model.service'):new()
local table_dao = require('application.models.dao.table'):new()
local UserService = {}

function UserService:get()
    table_dao:set('zhou', 'j')
    return table_dao.zhou
end

return UserService
]]


local bootstrap = [[
local Bootstrap = require('vanilla.v.bootstrap'):new(dispatcher)

function Bootstrap:initErrorHandle()
    self.dispatcher:setErrorHandler({controller = 'error', action = 'index'})
end

function Bootstrap:initRoute()
    local router = require('vanilla.v.routes.simple'):new(self.dispatcher:getRequest())
    self.dispatcher.router = router
end

function Bootstrap:initView()
end

function Bootstrap:boot_list()
    return {
        Bootstrap.initErrorHandle,
        Bootstrap.initRoute,
        Bootstrap.initView
    }
end

return Bootstrap
]]


local application_conf = [[
local Appconf={}
Appconf.name = '{{APP_NAME}}'

Appconf.route='vanilla.v.routes.simple'
Appconf.bootstrap='application.bootstrap'
Appconf.app={}
Appconf.app.root='/Users/zj-git/vanilla/pretty/'

Appconf.controller={}
Appconf.controller.path=Appconf.app.root .. 'application/controllers/'

Appconf.view={}
Appconf.view.path=Appconf.app.root .. 'application/views/'
Appconf.view.suffix='.html'
Appconf.view.auto_render=true

return Appconf
]]


local errors_conf = [[
-------------------------------------------------------------------------------------------------------------------
-- Define all of your application errors in here. They should have the format:
--
-- local Errors = {
--     [1000] = { status = 500, message = "Controller Err." },
-- }
--
-- where:
--     '1000'                is the error number that can be raised from controllers with `self:raise_error(1000)
--     'status'  (required)  is the http status code
--     'message' (required)  is the error description
-------------------------------------------------------------------------------------------------------------------

local Errors = {}

return Errors
]]


local nginx_config = [[
pid ]] .. va_conf.app_dirs.tmp .. [[/{{VA_ENV}}-nvanillax.pid;

# This number should be at maxium the number of CPU on the server
worker_processes 4;

events {
    # Number of connections per worker
    worker_connections 4096;
}

http {
    # use sendfile
    sendfile on;

    # Va initialization
    {{GIN_INIT}}

    server {
        # List port
        listen {{GIN_PORT}};

        # Access log with buffer, or disable it completetely if unneeded
        access_log ]] .. va_conf.app_dirs.logs .. [[/{{VA_ENV}}-access.log combined buffer=16k;
        # access_log off;

        # Error log
        error_log ]] .. va_conf.app_dirs.logs .. [[/{{VA_ENV}}-error.log;

        # Va runtime
        {{GIN_RUNTIME}}
    }
}
]]


local env_settings = [[
--------------------------------------------------------------------------------
-- Settings defined here are environment dependent. Inside of your application,
-- `va_conf.settings` will return the ones that correspond to the environment
-- you are running the server in.
--------------------------------------------------------------------------------

local Settings = {}

Settings.development = {
    code_cache = false,
    port = 7200,
    expose_api_console = true
}

Settings.test = {
    code_cache = true,
    port = 7201,
    expose_api_console = false
}

Settings.production = {
    code_cache = true,
    port = 80,
    expose_api_console = false
}

return Settings
]]


local index_controller_spec = [[
require 'spec.spec_helper'

describe("PagesController", function()

    describe("#root", function()
        it("responds with a welcome message", function()
            local response = hit({
                method = 'GET',
                path = "/"
            })

            assert.are.same(200, response.status)
            assert.are.same({ message = "Hello world from Va!" }, response.body)
        end)
    end)
end)
]]


local spec_helper = [[
require 'vanilla.spec.runner'
]]


local VaApplication = {}

VaApplication.files = {
    ['.gitignore'] = gitignore,
    ['application/controllers/index.lua'] = index_controller,
    ['application/controllers/error.lua'] = error_controller,
    ['application/library/.gitkeep'] = "",
    ['application/models/dao/table.lua'] = dao,
    ['application/models/service/user.lua'] = service,
    ['application/plugins/.gitkeep'] = "",
    ['application/views/index/index.html'] = index_tpl,
    ['application/views/error/error.html'] = error_tpl,
    ['application/bootstrap.lua'] = bootstrap,
    ['config/errors.lua'] = errors_conf,
    ['config/nginx.conf'] = nginx_config,
    ['config/env.lua'] = env_settings,
    ['spec/controllers/index_controller_spec.lua'] = index_controller_spec,
    ['spec/models/.gitkeep'] = "",
    ['spec/spec_helper.lua'] = spec_helper
}

function VaApplication.new(name)
    print(ansicolors("Creating app %{green}" .. name .. "%{reset}..."))

    VaApplication.files['config/application.lua'] = string.gsub(application_conf, "{{APP_NAME}}", name)
    VaApplication.create_files(name)
end

function VaApplication.create_files(parent)
    for file_path, file_content in pairs(VaApplication.files) do
        -- ensure containing directory exists
        local full_file_path = parent .. "/" .. file_path
        helpers.mkdirs(full_file_path)

        -- create file
        local fw = io.open(full_file_path, "w")
        fw:write(file_content)
        fw:close()
        print(ansicolors("  %{green}created file%{reset} " .. full_file_path))
    end
end

return VaApplication
