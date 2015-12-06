package = "vanilla"
version = "0.1.0.rc3-1"

source ={
    url ="git://github.com/idevz/vanilla.git"
}

description ={
    summary       ="A Lightweight Openresty Web Framework",
    homepage      ="http://idevz.github.io/vanilla",
    maintainer    ="zhoujing<zhoujing00k@gmail.com>",
    license       ="MIT",
    detailed = [[
##install
```
yum install lua-devel luarocks
luarocks install vanilla
```]]
}

dependencies ={
    "lua=5.1"
}

build = {
   type = "builtin",
   modules = {
      ["lua-resty-shcache.shcache"] = "lua-resty-shcache/shcache.lua",
      ["vanilla.sys.application"] = "vanilla/sys/application.lua",
      ["vanilla.sys.config"] = "vanilla/sys/config.lua",
      ["vanilla.sys.console"] = "vanilla/sys/console.lua",
      ["vanilla.sys.nginx.config"] = "vanilla/sys/nginx/config.lua",
      ["vanilla.sys.nginx.directive"] = "vanilla/sys/nginx/directive.lua",
      ["vanilla.sys.nginx.handle"] = "vanilla/sys/nginx/handle.lua",
      ["vanilla.sys.vanilla"] = "vanilla/sys/vanilla.lua",
      ["vanilla.sys.waf.acc"] = "vanilla/sys/waf/acc.lua",
      ["vanilla.sys.waf.config"] = "vanilla/sys/waf/config.lua",
      ["vanilla.v.application"] = "vanilla/v/application.lua",
      ["vanilla.v.bootstrap"] = "vanilla/v/bootstrap.lua",
      ["vanilla.v.controller"] = "vanilla/v/controller.lua",
      ["vanilla.v.dispatcher"] = "vanilla/v/dispatcher.lua",
      ["vanilla.v.error"] = "vanilla/v/error.lua",
      ["vanilla.v.libs.ansicolors"] = "vanilla/v/libs/ansicolors.lua",
      ["vanilla.v.libs.cookie"] = "vanilla/v/libs/cookie.lua",
      ["vanilla.v.libs.http"] = "vanilla/v/libs/http.lua",
      ["vanilla.v.libs.logs"] = "vanilla/v/libs/logs.lua",
      ["vanilla.v.libs.resty.cookie"] = "vanilla/v/libs/resty/cookie.lua",
      ["vanilla.v.libs.resty.http"] = "vanilla/v/libs/resty/http.lua",
      ["vanilla.v.libs.resty.http_headers"] = "vanilla/v/libs/resty/http_headers.lua",
      ["vanilla.v.libs.resty.logger.socket"] = "vanilla/v/libs/resty/logger/socket.lua",
      ["vanilla.v.libs.resty.session"] = "vanilla/v/libs/resty/session.lua",
      ["vanilla.v.libs.resty.session.ciphers.aes"] = "vanilla/v/libs/resty/session/ciphers/aes.lua",
      ["vanilla.v.libs.resty.session.ciphers.none"] = "vanilla/v/libs/resty/session/ciphers/none.lua",
      ["vanilla.v.libs.resty.session.encoders.base16"] = "vanilla/v/libs/resty/session/encoders/base16.lua",
      ["vanilla.v.libs.resty.session.encoders.base64"] = "vanilla/v/libs/resty/session/encoders/base64.lua",
      ["vanilla.v.libs.resty.session.encoders.hex"] = "vanilla/v/libs/resty/session/encoders/hex.lua",
      ["vanilla.v.libs.resty.session.serializers.json"] = "vanilla/v/libs/resty/session/serializers/json.lua",
      ["vanilla.v.libs.resty.session.storage.cookie"] = "vanilla/v/libs/resty/session/storage/cookie.lua",
      ["vanilla.v.libs.resty.session.storage.memcache"] = "vanilla/v/libs/resty/session/storage/memcache.lua",
      ["vanilla.v.libs.resty.session.storage.memcached"] = "vanilla/v/libs/resty/session/storage/memcached.lua",
      ["vanilla.v.libs.resty.session.storage.redis"] = "vanilla/v/libs/resty/session/storage/redis.lua",
      ["vanilla.v.libs.resty.session.storage.shm"] = "vanilla/v/libs/resty/session/storage/shm.lua",
      ["vanilla.v.libs.resty.shcache"] = "vanilla/v/libs/resty/shcache.lua",
      ["vanilla.v.libs.resty.template"] = "vanilla/v/libs/resty/template.lua",
      ["vanilla.v.libs.resty.template.html"] = "vanilla/v/libs/resty/template/html.lua",
      ["vanilla.v.libs.resty.template.microbenchmark"] = "vanilla/v/libs/resty/template/microbenchmark.lua",
      ["vanilla.v.libs.session"] = "vanilla/v/libs/session.lua",
      ["vanilla.v.libs.shcache"] = "vanilla/v/libs/shcache.lua",
      ["vanilla.v.libs.utils"] = "vanilla/v/libs/utils.lua",
      ["vanilla.v.plugin"] = "vanilla/v/plugin.lua",
      ["vanilla.v.registry"] = "vanilla/v/registry.lua",
      ["vanilla.v.request"] = "vanilla/v/request.lua",
      ["vanilla.v.response"] = "vanilla/v/response.lua",
      ["vanilla.v.router"] = "vanilla/v/router.lua",
      ["vanilla.v.routes.simple"] = "vanilla/v/routes/simple.lua",
      ["vanilla.v.view"] = "vanilla/v/view.lua",
      ["vanilla.v.views.rtpl"] = "vanilla/v/views/rtpl.lua"
   },
   install ={
      bin ={
      "bin/vanilla",
      "bin/vanilla-console"
      }
   },
}
