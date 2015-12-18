## Vanilla / (香草[中文文档](README-zh.md))
*Vanilla is An OpenResty Lua MVC Web Framework.*

![Vanilla](vanilla-en.png)

### *MailList*
vanilla-en <vanilla-en@googlegroups.com>

vanilla-devel <vanilla-devel@googlegroups.com>

vanilla中文邮件列表 <vanilla@googlegroups.com>

### *Install*
~~~
./configure --prefix=/usr/local/vanilla --openresty-path=/usr/local/openresty

make install
~~~

##### *configure*
Vanilla have default value for the options, but if your environment is different from the default value, please change it with yours.

And you can run ```make install``` after your configuration to install vanill.
```
./configure --help
  --help                                this message

  --prefix=PATH                         set the installation prefix (default to /usr/local/vanilla)
  --vanilla-bin-path=PATH               set vanilla bin path (default to /usr/local/bin)
  --platform=                           set platform(darwin, linux...)

  --openresty-path=PATH                 set openresty install path (default to /usr/local/openresty)
  --with-openresty-luajit-include-path=PATH
                                        set openresty luajit include path for install C moudle
                                        (like: /usr/local/openresty/luajit/include/luajit-2.1)
  --with-luajit-or-lua-bin=BIN          set openresty luajit or standard lua bin for run vanilla vanilla-console
                                        (default to $openresty_path/luajit/bin/luajit*)

  --without-lua-resty-cookie            disable the lua-resty-cookie library
  --without-lua-resty-template          disable the lua-resty-template library
  --without-lua-resty-http              disable the lua-resty-http library
  --without-lua-resty-logger-socket     disable the lua-resty-logger-socket library
  --without-lua-resty-session           disable the lua-resty-session library
  --without-lua-resty-shcache           disable the lua-resty-shcache library

  --with-lua-filesystem                 enable and build lua-filesystem
                                        (must need option --with-openresty-luajit-include-path)
```
##### *CMDS*
Vanilla provide two commands like ```vanilla```, and ```vanilla-console```, ```vanilla``` is for application building, service start, stop and so on, ```vanilla-console``` is an interactive command line， you can use it for debugging.

##### *How to use*
Run ```vanilla``` in command line, you can find command ```vanilla``` provide three options.
~~~
vanilla
Vanilla v0.1.0-rc3, A MVC web framework for Lua powered by OpenResty.

Usage: vanilla COMMAND [ARGS] [OPTIONS]

The available vanilla commands are:
 new [name]             Create a new Vanilla application
 start                  Starts the Vanilla server
 stop                   Stops the Vanilla server

Options:
 --trace                Shows additional logs
~~~

## Vanilla usage
##### *Building up an application skeleton*
```
vanilla new app_name
cd app_name
vanilla start [--trace]     -- default running in development environment.
VA_ENV=production vanilla start [--trace]  -- add VA_ENV to set the running environment.
```
##### *The code directory structure*
```
 /Users/zj-git/app_name/ tree ./
./
├── application（应用代码主体目录）
│   ├── bootstrap.lua（应用初始化 / 可选<以下未标可选为必选>）
│   ├── controllers(应用业务代码主体目录)
│   │   ├── error.lua（应用业务错误处理，处理本路径下相应业务报错）
│   │   └── index.lua（hello world示例）
│   ├── library（应用本地类包）
│   ├── models（应用数据处理类）
│   │   ├── dao（数据层业务处理）
│   │   │   └── table.lua
│   │   └── service（服务化业务处理，对DAO的再次封装）
│   │       └── user.lua
│   ├── nginx（*Openresty所封装Nginx请求处理各Phase）
│   │   └── init.lua（*init_by_lua示例）
│   ├── plugins（插件目录）
│   └── views（视图层，与controllers一一对应）
│       ├── error（错误模板）
│       │   └── error.html
│       └── index（index controller模板）
│           └── index.html
├── config（应用配置目录）
│   ├── application.lua（应用基础配置 / 路由器、初始化等设置）
│   ├── errors.lua（应用错误信息配置）
│   ├── nginx.conf（nginx配置文件模板）
│   ├── nginx.lua（服务各种运行环境配置 / 是否开启lua_code_cache等）
│   ├── waf-regs（应用防火墙规则配置目录）
│   │   ├── args
│   │   ├── cookie
│   │   ├── post
│   │   ├── url
│   │   ├── user-agent
│   │   └── whiteurl
│   └── waf.lua（服务防火墙配置）
├── logs（日志目录）
│   └── hack（攻击日志目录 / 保持可写权限）
├── pub（应用Nginx配置根路径）
│   └── index.lua（应用请求入口）
└── spec（基于busted的单元测试路径）
    ├── controllers
    │   └── index_controller_spec.lua
    ├── models
    └── spec_helper.lua
```
##### *demo IndexController*
```
local IndexController = {}

function IndexController:index()
    local view = self:getView()
    local p = {}
    p['vanilla'] = 'Welcome To Vanilla...'
    p['zhoujing'] = 'Power by Openresty'
    view:assign(p)
    return view:display()
end

return IndexController
```
##### *Template demo views/index/index.html*
```
<!DOCTYPE html>
<html>
<body>
  <img src="http://m1.sinaimg.cn/maxwidth.300/m1.sinaimg.cn/120d7329960e19cf073f264751e8d959_2043_2241.png">
  <h1><a href = 'https://github.com/idevz/vanilla'>{{vanilla}}</a></h1><h5>{{zhoujing}}</h5>
</body>
</html>
```

## Why You need Vanilla
回答这个问题，我们只需要看清楚Openresty和Vanilla各自做了什么即可。
#####*Openresty*
* 提供了处理HTTP请求的全套整体解决方案
* 给Nginx模块开发开辟了一条全新的道路，我们可以使用Lua来处理Web请求
* 形成了一个日趋完善的生态，这个生态涵盖了高性能Web服务方方面面 

#####*Vanilla*
* 基于Openresty开发，具备Openresty一切优良特性
* 实现了自动化、配置化的Nginx指令集管理
* 更合理的利用Openresty封装的8个处理请求Phase
* 支持不同运行环境（开发、测试、上线）服务的自动化配置和运行管理
* 使复杂的Nginx配置对Web业务开发者更透明化
* 开发者不再需要了解Openresty的实现细节，而更关注业务本身
* 实现了Web开发常规的调试，错误处理，异常捕获
* 实现了请求的完整处理流程和插件机制，支持路由协议、模板引擎的配置化
* 整合、封装了一系列Web开发常用的工具集、类库（cookie、应用防火墙等）
* 功能使用方便易于扩展

##社区组织
#####*QQ群&&微信公众号*
*Openresty/Vanilla开发QQ群：205773855（专题讨论Vanilla相关话题）*<br />
*Openresty 技术交流QQ群：34782325（讨论OpenResty和各种高级技术）*<br />
*Vanilla开发微信公众号:Vanilla-OpenResty(Vanilla相关资讯、文档推送)*


[![QQ](http://pub.idqqimg.com/wpa/images/group.png)](http://shang.qq.com/wpa/qunwpa?idkey=673157ee0f0207ce2fb305d15999225c5aa967e88913dfd651a8cf59e18fd459)