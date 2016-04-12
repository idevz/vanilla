## Vanilla / (香草[中文文档](README-zh.md)) / OSC [Git](http://git.oschina.net/idevz/vanilla)

[![https://travis-ci.org/idevz/vanilla.svg?branch=master](https://travis-ci.org/idevz/vanilla.svg?branch=master)](https://travis-ci.org/idevz/vanilla)
[![Join the chat at https://gitter.im/idevz/vanilla](https://badges.gitter.im/idevz/vanilla.svg)](https://gitter.im/idevz/vanilla?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Issue Stats](http://issuestats.com/github/idevz/vanilla/badge/pr)](http://issuestats.com/github/idevz/vanilla)
[![Issue Stats](http://issuestats.com/github/idevz/vanilla/badge/issue)](http://issuestats.com/github/idevz/vanilla)

*香草/Vanilla是一个基于Openresty实现的高性能Web应用开发框架.*

![Vanilla](vanilla-pub.png)

### *邮件列表*
- vanilla-en <vanilla-en@googlegroups.com>
- vanilla-devel <vanilla-devel@googlegroups.com>
- vanilla中文邮件列表 <vanilla@googlegroups.com>

### *安装*
*目前Vanilla支持两种安装方式*

- Make（推荐使用此种）
- Luarocks

#### *```make install```安装须知*
Vanilla 支持的选项都提供了默认值，如果你的环境与默认值不一样，请configure时指定成你自己的。

特别注意选项```--openresty-path```，默认为```/usr/local/openresty```，请确保设置正确。

可以在源码目录下执行```configure --help```来查看安装选项的使用方法。

下面是一个简单的安装示例：
```
./configure --prefix=/usr/local/vanilla --openresty-path=/usr/local/openresty

make install （如果没有C模块【目前支持lua-filesystem】，则不需要make，直接make install）
```
#### *```luarocks install```安装须知*
*可以使用luarocks安装vanilla，但是下面三点请注意*
1. Luarocks应该基于lua5.1.x的版本安装，因为其他版本Lua和Luajit的ABI存在兼容性问题。
2. Luarocks安装的Vanilla在nginx.conf文件的NGX_PATH变量不可用。
3. 请确保nginx命令可以直接运行（nginx命令在你的环境变量中）

### Vanilla 使用
#### *Vanilla命令*
*Vanilla 目前提供了两个命令 ```vanilla```，和 ```vanilla-console```*
- ```vanilla```用来初始化应用骨架，停启服务（添加--trace参数可以看到执行的命令）
- ```vanilla-console``` 是一个交互式命令行，主要提供一种方便学习Lua入门的工具，可以使用一些vanilla开发环境下的包，比如table输出的lprint_r方法。

命令行执行 ```vanilla```就能清晰看到 ```vanilla```命令提供的选项。

~~~
vanilla
Vanilla v0.1.0-rc3, A MVC web framework for Lua powered by OpenResty.

Usage: vanilla COMMAND [ARGS] [OPTIONS]

目前可用Vanilla命令选项如下:
 new [name]             创建一个名字为name的新应用
 start                  启动Vanilla应用 
 stop                   停止Vanilla应用
 restart				先停止再启动Vanilla应用
 reload					重新加载Vanilla应用中的nginx.conf文件

Options:
 --trace                显式显示日志
~~~

#### *创建应用*
```
vanilla new app_name
cd app_name
vanilla start [--trace]     -- 默认运行在development环境

## 在linux的bash环境下：
VA_ENV=production vanilla start [--trace]  -- 运行在生产环境
## 在BSD等tcsh环境下：
setenv VA_ENV production;vanilla start [--trace]  -- 运行在生产环境
```
#### *代码目录结构*
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
    └── index.lua（应用请求入口）
```
#### *业务代码示例 IndexController*
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
#### *模板示例 views/index/index.html*
```
<!DOCTYPE html>
<html>
<body>
  <img src="http://m1.sinaimg.cn/maxwidth.300/m1.sinaimg.cn/120d7329960e19cf073f264751e8d959_2043_2241.png">
  <h1><a href = 'https://github.com/idevz/vanilla'>{{vanilla}}</a></h1><h5>{{zhoujing}}</h5>
</body>
</html>
```

### 为什么需要Vanilla
回答这个问题，我们只需要看清楚Openresty和Vanilla各自做了什么即可。
#### *Openresty*

- 提供了处理HTTP请求的全套整体解决方案
- 给Nginx模块开发开辟了一条全新的道路，我们可以使用Lua来处理Web请求
- 形成了一个日趋完善的生态，这个生态涵盖了高性能Web服务方方面面 

#### *Vanilla*
- 使复杂的Nginx配置对Web业务开发者更透明化
- 开发者不再需要了解Openresty的实现细节，而更关注业务本身
- 实现了Web开发常规的调试，错误处理，异常捕获
- 实现了请求的完整处理流程和插件机制，支持路由协议、模板引擎的配置化
- 整合、封装了一系列Web开发常用的工具集、类库（cookie、应用防火墙等）
- 实现了自动化、配置化的Nginx指令集管理
- 更合理的利用Openresty封装的8个处理请求Phase
- 支持不同运行环境（开发、测试、上线）服务的自动化配置和运行管理
- 功能使用方便易于扩展
- 基于Openresty开发，具备Openresty一切优良特性

### 社区组织
#### *QQ群&&微信公众号*
- *Openresty/Vanilla开发QQ群：205773855（专题讨论Vanilla相关话题）*
- *Openresty 技术交流QQ群：34782325（讨论OpenResty和各种高级技术）*
- *Vanilla开发微信公众号:Vanilla-OpenResty(Vanilla相关资讯、文档推送)*


[![QQ](http://pub.idqqimg.com/wpa/images/group.png)](http://shang.qq.com/wpa/qunwpa?idkey=673157ee0f0207ce2fb305d15999225c5aa967e88913dfd651a8cf59e18fd459)
