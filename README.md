#vanilla
### One bouquet of vanilla
*Vanilla is An Openresty Web Framework For PHPER.*
<p><a href="http://idevz.github.io/vanilla/"><img border="0" src="https://avatars1.githubusercontent.com/u/2113827?v=3&s=460" alt="LuaRocks" width="150px"></a></p>

##install
```
yum install lua-devel luarocks
luarocks install https://raw.githubusercontent.com/idevz/vanilla/master/vanilla-0.0.1-1.rockspec
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