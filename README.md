## Vanilla / (香草[中文文档](README-zh.md)) / OSC [Git](http://git.oschina.net/idevz/vanilla)

[![https://travis-ci.org/idevz/vanilla.svg?branch=master](https://travis-ci.org/idevz/vanilla.svg?branch=master)](https://travis-ci.org/idevz/vanilla)
[![Join the chat at https://gitter.im/idevz/vanilla](https://badges.gitter.im/idevz/vanilla.svg)](https://gitter.im/idevz/vanilla?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)
[![Issue Stats](http://issuestats.com/github/idevz/vanilla/badge/pr)](http://issuestats.com/github/idevz/vanilla)
[![Issue Stats](http://issuestats.com/github/idevz/vanilla/badge/issue)](http://issuestats.com/github/idevz/vanilla)

*Vanilla is An OpenResty Lua MVC Web Framework.*

![Vanilla](vanilla-en.png)

### *MailList*
- vanilla-en <vanilla-en@googlegroups.com>
- vanilla-devel <vanilla-devel@googlegroups.com>
- vanilla中文邮件列表 <vanilla@googlegroups.com>

### *Install*
*There are two ways to install:*

- Make (recommended way)
- Luarocks

#### *Tips of ```make install```:*
*Vanilla support many configuration options, many of those option have default value.*

You can use default installation but if your enviroment values different from which vanilla default, please config it with yours.
Especially the ```--openresty-path``` option. you should make sure it's point to your turely OpenResty install path.
You can run command ```./configure --help``` to learn how to use those options. 

Below is the installation of a simple example:

~~~
./configure --prefix=/usr/local/vanilla --openresty-path=/usr/local/openresty

make install
~~~

#### *Tips of ```luarocks install```:*
*You can use luarocks to install vanilla, but three point should be clear:*

1. Your luarocks should install with lua5.1.x because of the compatibility problems in ABIs between Lua and Luajit.
2. parameter NGX_PATH will be disabled in the nginx.conf.
3. make sure that command nginx is in your environment PATH.

### Vanilla usage
#### *Vanilla CMDs*
*Vanilla provide two commands ```vanilla```, and ```vanilla-console```.*

- ```vanilla``` is for application building, service start, stop and so on.
- ```vanilla-console``` is an interactive command line， you can use it for debugging, testing, Lua learning...

Run ```vanilla``` in command line, you can find command ```vanilla``` provide three options.

```
vanilla
Vanilla v0.1.0-rc3, A MVC web framework for Lua powered by OpenResty.

Usage: vanilla COMMAND [ARGS] [OPTIONS]

The available vanilla commands are:
 new [name]             Create a new Vanilla application
 start                  Starts the Vanilla server
 stop                   Stops the Vanilla server
 restart				First Stops and then Starts the Vanilla servers
 reload					Reload nginx.conf of Vanilla server
 
Options:
 --trace                Shows additional logs
```

#### *Building up an application skeleton*
```
vanilla new app_name
cd app_name
vanilla start [--trace]     -- default running in development environment.
-- under bash on linux
VA_ENV=production vanilla start [--trace]  -- add VA_ENV to set the running environment.
-- under tcsh on BSD
setenv VA_ENV production ; vanilla start [--trace]  -- add VA_ENV to set the running environment.
```
#### *Directory Structure*
```
 /Users/zj-git/app_name/ tree ./
./
├── application
│   ├── bootstrap.lua --application boot
│   ├── controllers
│   │   ├── error.lua --application error handling, dealing with corresponding business under this path error
│   │   └── index.lua --vanilla hello world
│   ├── library       --local libs
│   ├── models 
│   │   ├── dao       --data handles for DB, APIs
│   │   │   └── table.lua
│   │   └── service   --encapsulations of DAOs
│   │       └── user.lua
│   ├── nginx         --openresy http phases
│   │   └── init.lua  --init_by_lua demo
│   ├── plugins
│   └── views         --one to one correspondence to controllers
│       ├── error     --error handle view layout
│       │   └── error.html
│       └── index     --index controller views
│           └── index.html
├── config
│   ├── application.lua --app basic configuration such as router,initialization settings...
│   ├── errors.lua    --app error conf
│   ├── nginx.conf    --nginx.conf skeleton
│   ├── nginx.lua     --nginx settings like lua_code_cache.
│   ├── waf-regs      --WAF rules
│   │   ├── args
│   │   ├── cookie
│   │   ├── post
│   │   ├── url
│   │   ├── user-agent
│   │   └── whiteurl
│   └── waf.lua       --app WAF config
├── logs
│   └── hack          --attack logs, keep path can be write
├── pub               --app content_by_lua_file path
    └── index.lua     --entrance file
```
#### *IndexController Demo*
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
##### *Template demo (views/index/index.html)*
```
<!DOCTYPE html>
<html>
<body>
  <img src="http://m1.sinaimg.cn/maxwidth.300/m1.sinaimg.cn/120d7329960e19cf073f264751e8d959_2043_2241.png">
  <h1><a href = 'https://github.com/idevz/vanilla'>{{vanilla}}</a></h1><h5>{{zhoujing}}</h5>
</body>
</html>
```

### Why Vanilla
*To answer this question, we just need to see what Openresty has done and Vanilla has done.*
#### *Openresty*
- Provides processing HTTP requests a full set of the overall solution
- Opened up a new way for Nginx module development, we can use Lua to deal with Web requests
- Formed an increasingly perfect ecology, the ecological covers all aspects of high-performance Web services 

#### *Vanilla*
- Implement a Web development routine debugging, error handling, exception handling
- Implement complete processing of the request and plug-in mechanism, support routing protocol, the template engine configuration
- Integration, encapsulates a series of Web development commonly used tool set, class library (cookies, application firewall, etc.)
- Features easy to use and extend
- Support  different environment (development, test, online)
- Focus on the business development, not any about nginx nor OpenResty
- Based on OpenResty, have all the good qualities of OpenResty
- Automated, Nginx instruction set of configuration management
- More reasonable use Openresty encapsulation of request processing Phase

### Community
#### *QQ Groups&&WeChat public no.*
- *Openresty/Vanilla Dev:205773855 (Vanilla panel discussion related topics)*
- *Openresty:34782325(Discuss OpenResty and all kinds of advanced technology)*
- *WeChat public no. of Vanilla Dev:Vanilla-OpenResty(Vanilla related information, document push)*


[![QQ](http://pub.idqqimg.com/wpa/images/group.png)](http://shang.qq.com/wpa/qunwpa?idkey=673157ee0f0207ce2fb305d15999225c5aa967e88913dfd651a8cf59e18fd459)
