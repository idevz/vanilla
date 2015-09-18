package ="vanilla"
version ="0.0.1-1"

source ={
    url ="git://github.com/idevz/vanilla.git"
}

description ={
    summary       ="A Openresty Web Framework For PHPER",
    homepage      ="http://idevz.github.io/vanilla",
    maintainer    ="zhoujing<zhoujing00k@gmail.com>",
    license       ="MIT"
}

dependencies ={
    "lua=5.1",
    "ansicolors=1.0.2-3",
    "busted=1.11.1",
    "lua-cjson=2.1.0-1",
    "luafilesystem=1.6.2-2",
    "penlight=1.3.1-1",
    "lua-resty-template=1.5-1"
}

build ={
    type ="builtin",
    modules ={
        ["vanilla.sys.application"]        ="vanilla/sys/application.lua",
        ["vanilla.v.application"]          ="vanilla/v/application.lua",
        ["vanilla.v.bootstrap"]            ="vanilla/v/bootstrap.lua",
        ["vanilla.sys.vanilla"]            ="vanilla/sys/vanilla.lua",
        ["vanilla.sys.application"]        ="vanilla/sys/application.lua",
        ["vanilla.sys.config"]             ="vanilla/sys/config.lua",
        ["vanilla.sys.nginx.handle"]       ="vanilla/sys/nginx/handle.lua",
        ["vanilla.sys.nginx.directive"]    ="vanilla/sys/nginx/directive.lua",
        ["vanilla.sys.nginx.config"]       ="vanilla/sys/nginx/config.lua",
        ["vanilla.v.controller"]           ="vanilla/v/controller.lua",
        ["vanilla.v.dispatcher"]           ="vanilla/v/dispatcher.lua",
        ["vanilla.v.error"]                ="vanilla/v/error.lua",
        ["vanilla.v.libs.utils"]           ="vanilla/v/libs/utils.lua",
        ["vanilla.v.libs.http"]            ="vanilla/v/libs/http.lua",
        ["vanilla.v.registry"]             ="vanilla/v/registry.lua",
        ["vanilla.v.request"]              ="vanilla/v/request.lua",
        ["vanilla.v.response"]             ="vanilla/v/response.lua",
        ["vanilla.v.routes.simple"]        ="vanilla/v/routes/simple.lua",
        ["vanilla.v.view"]                 ="vanilla/v/view.lua",
        ["vanilla.v.views.rtpl"]           ="vanilla/v/views/rtpl.lua",
    },
    install ={
        bin ={ "bin/vanilla" }
    },
}