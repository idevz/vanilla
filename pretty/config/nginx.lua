local ngx_conf = {}

ngx_conf.common = {
	INIT_BY_LUA = 'nginx.init',
	CONTENT_BY_LUA_FILE = './pub/index.lua'
}

ngx_conf.env = {}
ngx_conf.env.development = {
    LUA_CODE_CACHE = false,
    PORT = 7200
}

ngx_conf.env.test = {
    LUA_CODE_CACHE = true,
    PORT = 7201
}

ngx_conf.env.production = {
    LUA_CODE_CACHE = true,
    PORT = 80
}

return ngx_conf