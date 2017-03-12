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

## Features

- Provide many good components such as bootstrap, router, controllers, models, views.
- Powerful plugin system.
- Multi applications deployment.
- Multi version of framework coexistence, easier framwork upgrade.
- Auto complete the Nginx configration.
- A convenient way to manage Services.
- You only need to focus your business logic.

## Installation

##### *Vanilla-V0.1.0-rc4.1 Or the older Vanillas Installation to see: [README-V0.1.0-rc4.1.md](README/README-V0.1.0-rc4.1.md)*

``` bash
$ ./setup-framework -v $VANILLA_PROJ_ROOT -o $OPENRESTY_ROOT        #see ./setup-framework -h for more details
```

## Quick Start

**Setup your Own Application**

``` bash
$ ./setup-vanilla-demoapp  [-a $VANILLA_APP_ROOT -u $VANILLA_APP_USER -g $VANILLA_APP_GROUP -e $VANILLA_RUNNING_ENV]    #see ./setup-vanilla-demoapp -h for more details
```

**Start the server**

``` bash
$ ./$VANILLA_APP_ROOT/va-appname-service start
```

## More Information

- Read the [documentation](https://idevz.gitbooks.io/vanilla-doc/content/index.html)

## License

MIT


### Community
#### *QQ Groups&&WeChat public no.*
- *Openresty/Vanilla Dev:205773855 (Vanilla panel discussion related topics)*
- *Openresty:34782325(Discuss OpenResty and all kinds of advanced technology)*
- *WeChat public no. of Vanilla Dev:Vanilla-OpenResty(Vanilla related information, document push)*

[![QQ](http://pub.idqqimg.com/wpa/images/group.png)](http://shang.qq.com/wpa/qunwpa?idkey=673157ee0f0207ce2fb305d15999225c5aa967e88913dfd651a8cf59e18fd459)
