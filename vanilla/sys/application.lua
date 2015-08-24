-- dep
local ansicolors = require 'ansicolors'

-- gin
local Gin = require 'gin.core.gin'
local helpers = require 'gin.helpers.common'


local gitignore = [[
# gin
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



local pages_controller = [[
local PagesController = {}

function PagesController:root()
    return 200, { message = "Hello world from Gin!" }
end

return PagesController
]]


local errors = [[
-------------------------------------------------------------------------------------------------------------------
-- Define all of your application errors in here. They should have the format:
--
-- local Errors = {
--     [1000] = { status = 400, message = "My Application error.", headers = { ["X-Header"] = "header" } },
-- }
--
-- where:
--     '1000'                is the error number that can be raised from controllers with `self:raise_error(1000)
--     'status'  (required)  is the http status code
--     'message' (required)  is the error description
--     'headers' (optional)  are the headers to be returned in the response
-------------------------------------------------------------------------------------------------------------------

local Errors = {}

return Errors
]]


local application = [[
local Application = {
    name = "{{APP_NAME}}",
    version = '0.0.1'
}

return Application
]]


mysql = [[
local SqlDatabase = require 'gin.db.sql'
local Gin = require 'gin.core.gin'

-- First, specify the environment settings for this database, for instance:
-- local DbSettings = {
--     development = {
--         adapter = 'mysql',
--         host = "127.0.0.1",
--         port = 3306,
--         database = "{{APP_NAME}}_development",
--         user = "root",
--         password = "",
--         pool = 5
--     },

--     test = {
--         adapter = 'mysql',
--         host = "127.0.0.1",
--         port = 3306,
--         database = "{{APP_NAME}}_test",
--         user = "root",
--         password = "",
--         pool = 5
--     },

--     production = {
--         adapter = 'mysql',
--         host = "127.0.0.1",
--         port = 3306,
--         database = "{{APP_NAME}}_production",
--         user = "root",
--         password = "",
--         pool = 5
--     }
-- }

-- Then initialize and return your database:
-- local MySql = SqlDatabase.new(DbSettings[Gin.env])
--
-- return MySql
]]


local nginx_config = [[
pid ]] .. Gin.app_dirs.tmp .. [[/{{GIN_ENV}}-nginx.pid;

# This number should be at maxium the number of CPU on the server
worker_processes 4;

events {
    # Number of connections per worker
    worker_connections 4096;
}

http {
    # use sendfile
    sendfile on;

    # Gin initialization
    {{GIN_INIT}}

    server {
        # List port
        listen {{GIN_PORT}};

        # Access log with buffer, or disable it completetely if unneeded
        access_log ]] .. Gin.app_dirs.logs .. [[/{{GIN_ENV}}-access.log combined buffer=16k;
        # access_log off;

        # Error log
        error_log ]] .. Gin.app_dirs.logs .. [[/{{GIN_ENV}}-error.log;

        # Gin runtime
        {{GIN_RUNTIME}}
    }
}
]]


local routes = [[
local routes = require 'gin.core.routes'

-- define version
local v1 = routes.version(1)

-- define routes
v1:GET("/", { controller = "pages", action = "root" })

return routes
]]


local settings = [[
--------------------------------------------------------------------------------
-- Settings defined here are environment dependent. Inside of your application,
-- `Gin.settings` will return the ones that correspond to the environment
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


local pages_controller_spec = [[
require 'spec.spec_helper'

describe("PagesController", function()

    describe("#root", function()
        it("responds with a welcome message", function()
            local response = hit({
                method = 'GET',
                path = "/"
            })

            assert.are.same(200, response.status)
            assert.are.same({ message = "Hello world from Gin!" }, response.body)
        end)
    end)
end)
]]


local spec_helper = [[
require 'gin.spec.runner'
]]


local GinApplication = {}

GinApplication.files = {
    ['.gitignore'] = gitignore,
    ['app/controllers/pages_controller.lua'] = pages_controller,
    ['app/models/.gitkeep'] = "",
    ['config/errors.lua'] = errors,
    ['config/application.lua'] = "",
    ['config/nginx.conf'] = nginx_config,
    ['config/routes.lua'] = routes,
    ['config/settings.lua'] = settings,
    ['db/migrations/.gitkeep'] = "",
    ['db/schemas/.gitkeep'] = "",
    ['db/mysql.lua'] = "",
    ['lib/.gitkeep'] = "",
    ['spec/controllers/1/pages_controller_spec.lua'] = pages_controller_spec,
    ['spec/models/.gitkeep'] = "",
    ['spec/spec_helper.lua'] = spec_helper
}

function GinApplication.new(name)
    print(ansicolors("Creating app %{cyan}" .. name .. "%{reset}..."))

    GinApplication.files['config/application.lua'] = string.gsub(application, "{{APP_NAME}}", name)
    GinApplication.files['db/mysql.lua'] = string.gsub(mysql, "{{APP_NAME}}", name)
    GinApplication.create_files(name)
end

function GinApplication.create_files(parent)
    for file_path, file_content in pairs(GinApplication.files) do
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

return GinApplication
