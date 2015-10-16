#vanilla
### One bouquet of vanilla
*Vanilla is An Openresty Web Framework.*
<p><a href="http://idevz.github.io/vanilla/"><img border="0" src="https://avatars1.githubusercontent.com/u/2113827?v=3&s=460" alt="LuaRocks" width="150px"></a></p>

##install
```
yum install lua-devel luarocks
luarocks install vanilla
```

##set
```
content_by_lua_file ./pub/index.lua;
```

##useage
```
vanilla new app
cd app
vanilla start
```