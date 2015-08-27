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
