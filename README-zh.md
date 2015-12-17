##香草/Vanilla
*香草/Vanilla是一个基于Openresty实现的高性能Web应用开发框架.*

![Vanilla](http://m1.sinaimg.cn/maxwidth.300/m1.sinaimg.cn/120d7329960e19cf073f264751e8d959_2043_2241.png)

###安装说明
1. Vanilla使用Luarocks管理包依赖
2. 安装Luarocks（with lua5.1）
3. 使用Openresty最新稳定版

#####*安装示例 / Linux平台*
```
yum install lua-devel luarocks  -- 需要安装Lua开发版
luarocks install vanilla
```
#####*安装示例 / MacOSX平台*
```
wget lua5.1(lua5.1 源码地址)
源码安装lua5.1
wget luarocks（luarocks源码地址）
源码安装luarocks
luarocks install vanilla
```
#####*为何建议Lua5.1版本*
1. *Openresty执行Lua需要基于Luajit加速，Luajit使用Lua5.1的ABI*
2. *Luarocks会根据Lua版本识别相应的包*
3. *Vanilla运行Openresty前需要基于Lua5.1做服务相关自动化配置*

#####*为何建议源码安装*
1. *源码安装更方便版本控制*
2. *尤其MacOSX10.9后brew默认安装的Lua是5.2版本，而Openresty必须源码安装5.1*

##使用
#####*应用代码骨架生成及服务启动*
```
vanilla new app_name
cd app_name
vanilla start [--trace]     -- 默认运行在development环境
VA_ENV=production vanilla start [--trace]  -- 运行在生产环境
```
#####*代码目录结构说明*
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
#####*业务代码示例 IndexController*
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
#####*模板示例 views/index/index.html*
```
<!DOCTYPE html>
<html>
<body>
  <img src="http://m1.sinaimg.cn/maxwidth.300/m1.sinaimg.cn/120d7329960e19cf073f264751e8d959_2043_2241.png">
  <h1><a href = 'https://github.com/idevz/vanilla'>{{vanilla}}</a></h1><h5>{{zhoujing}}</h5>
</body>
</html>
```

##为什么需要Vanilla
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