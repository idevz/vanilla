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

####*Vanilla-V0.1.0-rc4.1 Or the older Vanillas Installation to see: [README-V0.1.0-rc4.1.md](README/README-V0.1.0-rc4.1.md)*

#### *Use ./setup-framework Install Vanilla*

*`./setup-framework` is a auto script to `make install` Vanilla, only need to set OpenResty install path to install Vanilla in a simple way*

```
./setup-framework -h
Usage: ./setup-framework
                 -h   show this help info
                 -v   VANILLA_PROJ_ROOT, vanilla project root, will contain vanilla framework and apps
                 -o   OPENRESTY_ROOT, openresty install path(openresty root)
```

Options of `./setup-framework`:

- -v : Set Vanilla project root, Default is `/data/vanilla`, So Vanilla installed at `/data/vanilla/framework/0_1_0_rc5/vanilla/` directory.

- -o : Set OpenResty install path, Default is `/usr/local/openresty`, if its different from your OpenResty install path,set to yours.

Here is the Directory Structure:

```
tree /data/vanilla -L 2
/data/vanilla
├── framework
│   ├── 0_1_0_rc5
│   └── 0_1_0_rc5.old_2016_04_12_11_04_18 # Repeat the installation will mv the older one to an time backup.
```

#### *Use ```make install``` cmd to install Vanilla*

*Vanilla support many configuration options, many of those option have default value.*

You can use default installation but if your enviroment values different from which vanilla default, please config it with yours.
Especially the ```--openresty-path``` option. you should make sure it's point to your turely OpenResty install path.
You can run command ```./configure --help``` to learn how to use those options. 

Below is the installation of a simple example:

```
./configure --prefix=/usr/local/vanilla --openresty-path=/usr/local/openresty

make install
```


### Vanilla usage

####*Vanilla-V0.1.0-rc4.1 Or the older Vanillas Installation to see: [README-zh-V0.1.0-rc4.1.md](README/README-zh-V0.1.0-rc4.1.md)*

#### *Vanilla CMDs*

*Vanilla-V0.1.0-rc5 always support two cmds, but from rc5, each cmd just like the framework itselvese generate with an  version number like ```vanilla-0.1.0.rc5```, and ```v-console-0.1.0.rc5```, this is good for muilt version vanilla coexistence and painless upgrade Vanilla.*
- ```vanilla-0.1.0.rc5``` use to init an app skeleton, after `vanilla-0.1.0.rc5` we use an script in the app root named `va-appname-service` to manage the app service but not `vanilla-0.1.0.rc5` cmd,  see below for the use details of script `va-appname-service`.
- ```v-console-0.1.0.rc5``` is an interactive command line, its mainly to provide a convenient learning Lua tools with many building Vanilla libs just like lprint_r fuction to output and table.

#### *Building up an application skeleton*
```
vanilla-0.1.0.rc5 new app_full_path							#use cmd `vanilla-0.1.0.rc5` to auto create an app skeleton, Attention to give an full path as an param, but not just an APP_NAME
chmod +x app_full_path/va-appname-service					#add an execute permissions to va-appname-service
app_full_path/va-appname-service initconf [dev]				#init the nginx config for the app, the nginx config file base on the config file in app_full_path/nginx_conf, if you have any personal configration, you should add thire into those config files first, then you can execute the initconf action, param [dev] is an optional one, add this for development environment, default empty for production environment.
app_full_path/va-appname-service start [dev]				#start this inited service, then you can visit it through http://localhost, it also have a [dev] option just like initconf.
```
These multi process can be simply completed through script `./setup-vanilal-demoapp`:
```
./setup-vanilal-demoapp -h
Usage: ./setup-vanilal-demoapp -h   show this help info
                 -a   VANILLA_APP_ROOT, app absolute path(which path to init app)
                 -u   VANILLA_APP_USER, user to run app
                 -g   VANILLA_APP_GROUP, user group to run app
                 -e   VANILLA_RUNNING_ENV, app running environment
```
Options of `./setup-vanilal-demoapp`
- -a : Set a abslute full path for Application, Default is `/data/vanilla/vademo`
- -u : Set the username to run nginx service, Default is idevz
- -g : Set the usergroup to run nginx service, Default is sina
- -e : Set the running enviroment, Default is '' for production environment.

Here is the Directory Structure:

```
tree /data/vanilla/ -L 1
/data/vanilla/
├── framework 							# vanilla framework path
├── vademo 								# demo app "vademo" path
└── vademo.old_2016_04_12_11_04_26 		# Repeat the installation will mv the older one to an time backup.
```

#### *Application init and service management*
*We use script `/data/vanilla/vademo/va-vademo-service` to manage the vademo service*

```
/data/vanilla/vademo/va-vademo-service -h
Usage: ./va-ok-service {start|stop|restart|reload|force-reload|confinit[-f]|configtest} [dev] #dev set up the running environment, none dev for default production envionment.
```

Tips:* You should run cmd `/data/vanilla/vademo/va-vademo-service initconf [dev]` first if you new the App didn't use the `/data/vanilla/vademo/va-vademo-service` script but run cmd `vanilla-0.1.0.rc5 new vademo` to new an app by hand.*

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
