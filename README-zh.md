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


## 特性

- 提供很多优良组件诸如：bootstrap、 router、 controllers、 models、 views。
- 强劲的插件体系。
- 多 Application 部署。
- 多版本框架共存，支持便捷的框架升级。
- 一键 nginx 配置、 应用部署。
- 便捷的服务批量管理。
- 你只需关注自身业务逻辑。

## 安装

##### *Vanilla-V0.1.0-rc4.1 或之前版本的 Vanilla 安装请参见 ： [README-V0.1.0-rc4.1.md](README/README-zh-V0.1.0-rc4.1.md)*

``` bash
$ ./setup-framework -v $VANILLA_PROJ_ROOT -o $OPENRESTY_ROOT        #运行 ./setup-framework -h 查看更多参数细节
```

## 快速开始

**部署你的第一个Vanilla Application**

``` bash
$ ./setup-vanilla-demoapp  [-a $VANILLA_APP_ROOT -u $VANILLA_APP_USER -g $VANILLA_APP_GROUP -e $VANILLA_RUNNING_ENV]    #运行 ./setup-vanilla-demoapp -h  查看更多参数细节
```

**启动你的 Vanilla 服务**

``` bash
$ ./$VANILLA_APP_ROOT/va-appname-service start
```

## 更多信息

- 参见 [文档](https://idevz.gitbooks.io/vanilla-zh/content/index.html)

## License

MIT


### 社区组织
#### *QQ群&&微信公众号*
- *Openresty/Vanilla 开发 1 群：205773855*
- *Openresty/Vanilla 开发 2 群：419191655*
- *Openresty 技术交流 1 群：34782325*
- *Openresty 技术交流 2 群：481213820*
- *Openresty 技术交流 3 群：124613000*
- *Vanilla开发微信公众号:Vanilla-OpenResty(Vanilla相关资讯、文档推送)*


[![QQ](http://pub.idqqimg.com/wpa/images/group.png)](http://shang.qq.com/wpa/qunwpa?idkey=673157ee0f0207ce2fb305d15999225c5aa967e88913dfd651a8cf59e18fd459)
